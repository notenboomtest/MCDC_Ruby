#!/usr/bin/env ruby

class Condition
	attr_accessor :name, :precop, :trailop
end

class Testcase
	attr_accessor :seq, :res
	def initialize(seq, res)
		@seq = seq
		@res = res
	end
end

class Decision
	attr_reader :conditions, :testcases

	def initialize
		@conditions = []
		@testcases = []
	end

	def extract(raw)
		elem = raw.split(//)
		size = elem.length
		i = 0
		while i < size do
			temp = Condition.new
			temp.name = elem[i]
			temp.precop = i == 0 ? "-" : elem[i - 1]
			temp.trailop = (i + 1) == size ? "-" : elem[i + 1]
			@conditions[i / 2] = temp
			i += 2
		end
	end

	def derivation
		testcase= []
		@conditions.each_index do |i|
			testcase[i] = "1"
			len = @conditions.length
			(i+1).upto(len-1) do |x|
				testcase[x] = @conditions[x].precop == "&" ? "1" : "0"
			end
			0.upto(len - (len - i) - 1) do |x|
				testcase[x] = @conditions[x].trailop == "&" ? "1" : "0"
			end
			@testcases[i] = Testcase.new(testcase.join, "True")
			testcase[i] = "0"
			@testcases[i + len] = Testcase.new(testcase.join, "False")
			testcase.clear
		end
	end

	def reduce
		list= []
		temp= []
		@testcases.each do |testcase|
			unless list.find_index(testcase.seq)
				list.push(testcase.seq)
				temp.push(testcase)
			end
		end
		@testcases.clear
		@testcases = temp
	end

	def print_solution
		printf"      "
		@conditions.each do |condition|
			printf "#{condition.name} "
		end
		printf "  Result"
		puts
		number = 0
		@testcases.each do |testcase|
			solutions = testcase.seq.split(//)
			number += 1
			printf "TC%s:  ", number
			solutions.each do |solution|
				printf "#{solution} "
			end
			printf "  #{testcase.res}"
			puts
		end
	end

	def print_file_solution(file)
		f = File.new(file, "w")
		f.printf"      "
		@conditions.each do |c|
			f.printf "%s ", c.name
		end
		f.printf "  Result"
		f.puts
		number = 0
		@testcases.each do |x|
			sol = x.seq.split(//)
			number += 1
			f.printf "TC%s:  ", number
			sol.each do |s|
				f.printf "%s ", s
			end
			f.printf "  %s", x.res
			f.puts
		end
		f.close
	end
end

file = ARGV.empty? ? "" : ARGV[0]
print "Give a decision in the form A&B|C (ignore parenthesis): "
decision = Decision.new
decision.extract($stdin.gets)
decision.derivation
decision.reduce
if file == ""
		decision.print_solution
else
		decision.print_file_solution(file)
end
