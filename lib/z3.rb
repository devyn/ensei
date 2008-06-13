#!ruby
# added on-demand gzip to lessen mem usage
# added json metadata
# added archive metadata
%w(zlib base64 stringio set fileutils json).each{|r|require r}

class Object
	def full_clone
		Marshal.load(Marshal.dump(self))
	end
end

class Z3
	TABLE = {
		:magic => 'Z3',
		:begin => "\250",
		:filestart => "\251",
		:filenext => "\252",
		:end => "\253",
		:jsonstart => "\254"
	}
	RANKS = ["bytes", "kilobytes", "megabytes", "gigabytes", "terrabytes"]
	def initialize(file=nil)
		@files = {}
		@mdata = {}
		@adata = {}
		unpack file if file
	end
	def self.from_file(filename)
		Z3.new(File.read(filename))
	end
	def self.zip(pathname, filename)
		from_physical(pathname).to_file(filename)
		true
	end
	def self.unzip(filename, pathname)
		from_file(filename).extract(pathname)
		true
	end
	def to_physical(pathname)
		# initialize directories
		dirs.each do |dir|
			FileUtils.mkdir_p File.join(File.expand_path(pathname), dir)
		end
		# save files
		files.each do |file|
			File.open File.join(File.expand_path(pathname), file), "w" do |f|
				f.write @files[file]
			end
		end
		true
	end
	alias extract to_physical
	def self.from_physical(pathname)
		files = get_local_recursive(File.expand_path(pathname))
		z3 = Z3.new
		files.each do |file|
			z3.open(File.join("/", file.sub(File.expand_path(pathname), ""))) do |zf|
				zf.write File.read(file)
			end
		end
		return z3
	end
	def metadata(filename)
		if filename == :archive
			return @adata
		else
			return @mdata[filename]
		end
	end
	def to_file name
		File.open(name,'w'){|f|f.write save}
	end
	def files
		@files.keys
	end
	def things_in dir
		a = []
		dir = dir.gsub(%r" $|/$", "") unless dir =~ %r"^/ *$"
		a << (dirs.select{|dname|File.dirname(dname) == dir}-[dir]).collect{|d|d+"/"}
		a << @files.select{|fname,cont|File.dirname(fname) == dir}.collect{|ia|ia[0]}
		return a
	end
	def dirs
		d = Set.new
		@files.each{|fname,cont|d << File.dirname(fname)}
		return d.to_a
	end
	def open(filename)
		(@files[filename] = "") and (@mdata[filename] = {}) unless @files[filename]
		@files[filename] = Zlib::Inflate.inflate(Base64.decode64(@files[filename])) unless @files[filename].empty?
		ret = yield StringIO.new(@files[filename])
		@files[filename] = Base64.encode64(Zlib::Deflate.deflate(@files[filename]))
		return ret
	end
	def read(filename)
		return false unless @files[filename]
		open(filename){|f|f.read}
	end
	def delete(filename)
		return false unless @files[filename]
		@files.delete filename
		@mdata.delete filename
		true
	end
	def move(src, dest)
		copy(src, dest) and delete(src)
		
	end
	def copy(src, dest)
		return false unless @files[src]
		@files[dest] = @files[src]
		@mdata[dest] = @mdata[src]
		true
	end
	def size(filename)
		return false unless @files[filename]
		Zlib::Inflate.inflate(Base64.decode64(@files[filename])).size
	end
	def csize(filename)
		return false unless @files[filename]
		@files[filename].size
	end
	def about(filename)
		return "File not found." unless @files[filename]
		compressed = @files[filename].size
		uncompressed = size(filename)
		crank = 0
		until compressed < 1000
			compressed /= 1000
			crank += 1
		end
		urank = 0
		until uncompressed < 1000
			uncompressed /= 1000
			urank += 1
		end
		return "#{filename}: #{uncompressed} #{RANKS[urank]} (#{compressed} #{RANKS[crank]} compressed)"
	end
	def save
		TABLE[:magic]+JSON.dump(@adata)+TABLE[:begin]+@files.to_a.collect{|f|f[0]+TABLE[:jsonstart]+JSON.dump(@mdata[f[0]])+TABLE[:filestart]+Base64.encode64(Zlib::Deflate.deflate(f[1])).gsub("\n", "")}.join(TABLE[:filenext])+TABLE[:end]
	end
	def unpack(file)
		raise ArgumentError, "Not Z3 File" unless file =~ /^#{TABLE[:magic]}/
		@adata = JSON.load(file[(TABLE[:magic].size)..(file.index(TABLE[:begin]))].sub(/#{TABLE[:begin]}$/, ""))
		encfiles = file[(file.index(TABLE[:begin]))..(file.index(TABLE[:end]))].gsub(/^#{TABLE[:begin]}|#{TABLE[:end]}$/, "").split(TABLE[:filenext])
		encfiles.each do |f|
			fj = f.split(TABLE[:jsonstart])
			fs = fj[1].split(TABLE[:filestart])
			@files[fj[0]] = fs[1]
			@mdata[fj[0]] = JSON.load(fs[0])
		end
	end
	def inspect
		directories=""
		if dirs.size == 1
			directories= "1 directory"
		else
			directories= "#{dirs.size} directories"
		end
		if @files.size == 1
			return "(Z3: 1 file in #{directories})"
		else
			return "(Z3: #{@files.size} files in #{directories})"
		end
	end
	private
	def self.get_local_recursive(pathname)
		a = []
		(Dir.entries(pathname) - %w(. ..)).each do |e|
			if File.directory? File.join(pathname, e)
				a += get_local_recursive(File.join(pathname, e))
			else
				a << File.join(pathname, e)
			end
		end
		return a
	end
end
