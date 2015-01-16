require 'faker'
require_relative "Person.rb"	

PASSW_LENGTH_MIN = 10
PASSW_LENGTH_MAX = 20

class Client
	@@curindex = 1

attr_accessor :curindex, :id, :person, :person, :login, :password

	def initialize
		@id = @@curindex
		@@curindex +=1
		@person = Person.new
		@login = Faker::Internet.user_name
		@pass = Faker::Internet.password(PASSW_LENGTH_MIN,PASSW_LENGTH_MAX)
	end
end


class CompanyClient < Client
attr_accessor :companyName, :phone, :fax, :email

	def initialize
		super
		@companyName = Faker::Company.name + " " +  Faker::Company.suffix
		@phone = Faker::Number.number(TELEPHONE_N_LENGTH)
		@fax = Faker::Number.number(TELEPHONE_N_LENGTH)
		@email = "contact@#{@companyName}.com".gsub(" ", "")
		@login = @companyName.downcase.gsub(" ", "").gsub(",", " ")
	end

	def to_s
		"#{@person}, \"#{@companyName}\", #{@phone}, #{@fax}, \"#{@email}\", \"#{@login}\", \"#{@pass}\", 1"
	end
	def export
		"exec dbo.DodajKlientaFirm #{to_s}; \n"
	end

end

class IndClient < Client
attr_accessor :companyName, :phone, :fax, :email

	def initialize
		super
		@email = "#{@person.firstName}#{@person.lastName}@memail.com".downcase.gsub(" ", "")
		@login = "#{@person.firstName}#{@person.lastName}".downcase.gsub(" ", "").gsub(",", " ")
	end

	def to_s
		"#{@person}, \"#{@email}\", \"#{@login}\", \"#{@pass}\", 0"
	end
	def export
		"exec dbo.DodajKlientaInd #{to_s}; \n"
	end

end

20.times {puts CompanyClient.new.export}
20.times {puts IndClient.new.export}


