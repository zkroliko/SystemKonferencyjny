require 'faker'
require_relative 'Supporting'
require_relative 'Conference'

WORKSHOP_PLACES_ROUNDING = -1
WORKSHOP_BASIC_PLACES = 200	
WORKSHOP_VARIABLE_PLACES = 90

WORKSHOP_PRICE_ROUNDING = -1
WORKSHOP_BASIC_PRICE = 20
WORKSHOP_VARIABLE_PRICE = "dependant"
WORKSHOP_MAX_PRICE = 200

#How many workshop can there be per conference day
WORKSHOP_PER_CONF_DAY_BASE = 2
WORKSHOP_PER_CONF_DAY_MAX_DIFF = 2

#Maximal time worshop can take
WORKSHOP_MAX_LENGTH = 5

#In what time windows can workshops occur
WORK_HOUR_MIN = Time.new(2000, 01, 01, 8, 0, 0, "+01:00")
WORK_HOUR_MAX = Time.new(2000, 01, 01, 19, 0, 0, "+01:00")
#Maximal and minimal workshop length
WORK_TIME_MIN = 60*60 # in second
WORK_TIME_MAX = 240*60 # in second

class Workshop

	@@curindex = 1
		
	# For holding the collision data about workshops
	@@collisions = Hash.new

	attr_accessor :curindex, :id, :name, :places, :leftPlaces, :conference, :price

	attr_reader :days

	# Special accesor for :leftPlaces, because they can run out
	def leftPlaces=(leftPlaces)
    		@leftPlaces = leftPlaces
		if (leftPlaces < 0)
			"We ran out of space at this workshop"		
		end
 	end


	def initialize(conference = 'null')
		@id = @@curindex
		@@curindex +=1
		@name = getSomeCoolName
		@places = (rand()*WORKSHOP_VARIABLE_PLACES).round(WORKSHOP_PLACES_ROUNDING)+WORKSHOP_BASIC_PLACES
		# Now something out of oridinary, what will make things easier
		# by remebering how many places there ale left
		@leftPlaces = @places
		# Randomizes price
		@price = (((Faker::Commerce.price).to_int+WORKSHOP_BASIC_PRICE)%WORKSHOP_MAX_PRICE).round(WORKSHOP_PRICE_ROUNDING)
		@conference = conference
		# Setting up the workshop days, randomizing start and end days
		startDate = Date.new
		endDate = Date.new
		while !((endDate-startDate) > 0 and (endDate-startDate) < WORKSHOP_MAX_LENGTH) do
			startDate = Faker::Date.between(conference.startDate, conference.endDate)
			endDate = Faker::Date.between(startDate, conference.endDate)
		end
		@choosenDays = (@conference.days).select{|x| x if (startDate <= x.date and x.date <= endDate)}
		# Now we have a subset of conference days
		@days = Array.new
		@choosenDays.each{|x| @days << (WDay.new((x), self))}
	end

	def getSomeCoolName
		names = File.open("NazwyWarsztatow").read.split("\n")
		names[rand(names.size)]
	end

	# Checks whether two Workshops collide
	def self.collide first, second
		# First let check whether there is an entry for this combination
		if @@collisions.has_key?([first.id, second.id])
			return @@collisions[[first.id, second.id]]			
		end
		# Apparently not
		# Checking whether we have common days
		dayCollision = first.days.map{|x| x.cday} & second.days.map{|x| x.cday}
		if dayCollision.empty?
			@@collisions[[first.id, second.id]] = false # We add it too look up table 
			return false			
		else	
			# There is an intersection
			# Now let's check for REAL intersections
			collision = dayCollision.select do |day|
				# Hell this is ugly
				firstStart = first.days[first.days.map{|x| x.cday}.index(day)].startTime
				firstEnd= first.days[first.days.map{|x| x.cday}.index(day)].endTime
				secondStart = second.days[second.days.map{|x| x.cday}.index(day)].startTime
				secondEnd= second.days[second.days.map{|x| x.cday}.index(day)].endTime
				if (firstStart > secondStart and firstStart < secondEnd) or (firstEnd > secondStart and firstEnd < secondEnd)
					@@collisions[[first.id, second.id]] = true # We add it too look up table 
					return true # There is your problem!
				end
			end
		# At last we can say that there is no collision
		@@collisions[[first.id, second.id]] = false # We add it too look up table 
		return false
		end
	end

	# Function for finding non-colliding subset of workshops given as an argement
	# it also takes a size of the requested subster as parameter, with default 
	# as the size of a given array
	# It means, that it will find the biggest possible subset
	def self.pickNoncolliding workshops, targetAmmountOfWorkshops = workshops.size

			# Counter, if the algorithm can find no solution for long enough
			# we will reduce the size of the subset
			counter_max = 10 # default 10
			counter = 0
			# Condition
			collide = true		
			# The picked workshops
			workshopsTemp = Array.new
			# We will execute this loop until we get proper, not colliding workshops
			while (collide == true) do	
				# For now, we haven't found any
				collide = false
				# First let's whether 
				if (counter == counter_max)
					# He tried long enough, let's check with softer rules
					targetAmmountOfWorkshops -= 1 
					counter = 0
				end
				workshopsTemp = workshops.sample(targetAmmountOfWorkshops)
				# Select the ones that collide
				 workshopsTemp.each do |work|
					workshopsTemp.select{|work2| work2 != work}.find do |work2|
						collide = Workshop.collide(work, work2)
					end
				end
				counter += 1 # We increase the counter
			end
			return workshopsTemp
	end

	def to_s
		"\"#{name}\", #{@places}, \"#{@price}\""
	end

	def export
		"exec dbo.DodajWarsztat #{to_s}\n#{(@days.collect{|x| x.export}).join("\n")}"
	end

end

class WDay
	@@curindex = 1

	attr_accessor :curindex, :id, :cday, :workshop, :startTime, :endTime

	def initialize(cDay, workshop)
		@id = @@curindex
		@@curindex +=1
		@workshop = workshop
		@cday = cDay
		# Now for staring and ending hours
		begin
			@startTime = (NormalizeTimeToDate(cday.date, WORK_HOUR_MIN) + (rand()*((WORK_HOUR_MAX-WORK_HOUR_MIN)-WORK_TIME_MAX)).to_i).round(5*60)
			@endTime = (@startTime +rand()*WORK_TIME_MAX).round(30*60)
		end while (@endTime-@startTime < 60*60 or @endTime < @startTime)
	end

	def to_s
		"#{@cday.id}, #{(@workshop.id)}, \"#{@startTime.to_s[11..18]}\", \"#{@endTime.to_s[11..18]}\""
	end

	def export 
		"exec dbo.DodajDzienWarsztatu #{to_s}"
	end
end
