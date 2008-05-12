# Resh2: A Pipe-based shell language based on Ruby
module Resh
	VERSION = 2.0
	PRODUCT = "Resh"
	class ReshExit < Exception; end
	class CommandDescriptor
		def metaclass; class << self; self; end; end
		# note: commands have full access to instance variables
		def define(name, code=nil, &blk)
			if code and not blk then blk = proc{instance_eval(code)} end
			metaclass.__send__(:define_method, name, &blk)
			@commands << name.to_s unless @commands.include?(name.to_s)
		end
		def call(name, *args, &blk)
			if @commands.include? name.to_s
				send name, *args, &blk
			else
				raise NoMethodError, "command #{name} not found."
			end
		end
		def initialize
			@commands = %w(quit exit)
		end
		def exit(pipedata, arguments)
			raise ReshExit, "internal exit"
		end
		alias quit exit
		def process_args(argumentString)
			return [] unless argumentString
			a = argumentString.split(" ")
			_start = 0
			_end = 0
			a.each_with_index do |i,ind|
				if i =~ /^"/
					_start = ind
				elsif i =~ /"$/
					_end = ind
					a[_start.._end] = a[_start.._end].join(" ").gsub(/^"|"$/, "")
				elsif i =~ /^""$/
					a[ind] = ""
				end
			end
			_start = 0
			_end = 0
			a.each_with_index do |i,ind|
				if i =~ /^'/
					_start = ind
				elsif i =~ /'$/
					_end = ind
					a[_start.._end] = a[_start.._end].join(" ").gsub(/^'|'$/, "")
				elsif i =~ /^''$/
					a[ind] = ""
				end
			end
			return a
		end
	end
	class InputTokens < Array
		def initialize(code)
			a = code.split(/[ \n]*;[ \n]*/)
			a.each_with_index {|i, ind|
				a[ind] = i.split(/[ \n]*\|[ \n]*/)
				a[ind].each_with_index {|ii, iind|
					a[ind][iind] = ii.split(/[ \n]*\&[ \n]*/)
				}
			}
			concat a
		end
		def to_s
			a = dup
			s = ""
			a.each_with_index {|i, ind|
				a[ind].each_with_index {|ii, iind|
					a[ind][iind].each_with_index {|iii, iiind|
						s << iii
						s << "&" unless (iiind == (a[ind][iind].size - 1))
					}
					s << "|" unless iind == (a[ind].size - 1)
				}
				s << ";" unless ind == (a.size - 1)
			}
			return s
		end
		# not the best for performance, but still valid.
		def to_pretty
			a = dup
			s = ""
			a.each_with_index {|i, ind|
				a[ind].each_with_index {|ii, iind|
					a[ind][iind].each_with_index {|iii, iiind|
						s << iii
						s << " &\n" unless (iiind == (a[ind][iind].size - 1))
					}
					s << "\n| " unless iind == (a[ind].size - 1)
				}
				s << " ;\n\n" unless ind == (a.size - 1)
			}
			return s
		end
	end
	class Executor
		attr :des
		def initialize(descriptor=nil)
			descriptor = Resh::CommandDescriptor.new unless descriptor
			@des = descriptor
		end
		def execute(tokens)
			tokens = Resh::InputTokens.new(tokens) if tokens.class >= String
			last_pipe_data = []
			for segment in tokens
				for pipe_part in segment
					pipe_data = []
					for command in pipe_part
						begin
							pipe_data << @des.call(command.split(" ")[0], last_pipe_data, command.split(" ")[1..-1].join(" "))
						rescue ReshExit
							raise $!
						rescue Exception
							pipe_data << $!
						end
					end
					last_pipe_data = pipe_data
				end
			end
			last_pipe_data
		end
		def interactive(simple_prompt=true, input_stream=STDIN, output_stream=STDOUT)
			output_stream.write(simple_prompt ? ">> " : "#{Resh::PRODUCT}#{Resh::VERSION}> ")
			x = execute(InputTokens.new(input_stream.readline.chomp))
			xes = ""
			x.each_with_index do |i,ind|
				xes << i.inspect
				xes << " & " unless ind == (x.size - 1)
			end
			puts "=> #{xes}\n"
			return x
		end
		def interactive_loop(simple_prompt=true, input_stream=STDIN, output_stream=STDOUT)
			begin
				loop do
					interactive simple_prompt, input_stream, output_stream
				end
			rescue ReshExit
				return
			end
		end
	end
end
