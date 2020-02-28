# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'protocol/http/body/readable'

module Protocol
	module HTTP1
		module Body
			class Chunked < HTTP::Body::Readable
				# TODO maybe this should take a stream rather than a connection?
				def initialize(stream)
					@stream = stream
					@finished = false
					
					@length = 0
					@count = 0
				end
				
				def empty?
					@finished
				end
				
				def close(error = nil)
					# We only close the connection if we haven't completed reading the entire body:
					unless @finished
						@stream.close
						@finished = true
					end
					
					super
				end
				
				def read
					return nil if @finished
					
					length = read_line.to_i(16)
					
					if length == 0
						@finished = true
						read_line
						
						return nil
					end
					
					chunk = @stream.read(length)
					read_line # Consume the trailing CRLF
					
					@length += length
					@count += 1
					
					return chunk
				end
				
				def inspect
					"\#<#{self.class} #{@length} bytes read in #{@count} chunks>"
				end
				
				private
				
				def read_line
					@stream.gets(chomp: true)
				end
			end
		end
	end
end
