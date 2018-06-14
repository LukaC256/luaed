print("Basic Lua Text Editor")
print("Type 'help' for a list of commands")
print("==================================")

text = {}
std_filename = ""

function print_help()
	print("load : Load File")
	print("save : Save File")
	print("list : Print all lines")
	print("cat  : Print single line")
	print("app  : Append Line")
	print("mapp : Append multiple Lines")
	print("led  : Edit Line")
	print("mled : Edit Multiple Lines")
	print("ins  : Insert line")
	print("mins : Insert multiple lines")
	print("rln  : Remove line")
	print("cln  : Remove all Lines")
	print("stat : Print information")
	print("help : Print this Text")
	print("exit : leave program")
end

function append()
	io.write("*> ")
	local line = io.read()
	table.insert(text, line)
end

function append_multiple(caption)
	print("Appending lines until caption '"..caption.."'")
	while true do
		io.write("*> ")
		local line = io.read()
		if line == caption then
			break
		end
		table.insert(text, line)
	end
end

function remove_line(ln)
	if ln < 1 or ln > #text then return end
	table.remove(text, ln)
end

function list()
	for i, line in ipairs(text) do
		print(i.." : "..line)
	end
end

function print_status()
	print("Lines: "..#text)
	local bytes = 0
	for i, line in ipairs(text) do
		bytes = bytes + #line + 1
	end
	print("Bytes: "..bytes)
	print("Filename: "..std_filename)
end

function save_file()
	io.write("Please enter Filename: ")
	local filename = io.read()
	if filename == "" then
		filename = std_filename
	end
	local file, error = io.open(filename, "w")
	if not file then 
		print("File IO Error: "..error)
		return
	end
	for i, line in ipairs(text) do
		file:write(line.."\n")
	end
	file:close()
	std_filename = filename
	print_status()
	print("Save succeeded!")
end

function confirm_clean()
	if not text[1] then return true end
	print("The following Operation will clean the current buffer! Continue? [Y,n]")
	if string.lower(io.read()) == "y" then
		text = {}
		std_filename = ""
		return true
	else
		return false
	end
end

function load_file()
	if not confirm_clean() then return end
	io.write("Please enter Filename: ")
	local filename = io.read()
	local file, error = io.open(filename, "r")
	if not file then
		print("File IO Error: "..error)
		return
	end
	for line in file:lines("l") do
		table.insert(text, line)
	end
	file:close()
	std_filename = filename
	print("Load successful!")
	print_status()
end

while true do
	io.write("-> ")
	local input = io.read()
	local parsecnt = 1
	local command = ""
	local param = ""
	for w in string.gmatch(input, "%g+") do
		if parsecnt == 1 then
			command = w
			parsecnt = 2
		else
			param = w
			break
		end
	end
	if command == "exit" then
		io.write("Do you really want to exit? [Y,n] ")
		if string.lower(io.read()) == "y" then
			break
		end
	elseif command == "help" then
		print_help()
	elseif command == "app" then
		append()
	elseif command == "mapp" then
		if param == "" then 
			print("SYNTAX ERROR! Missing caption!")
		else
			append_multiple(param)
		end
	elseif command == "list" then
		list()
	elseif command == "cln" then
		text = {}
		std_filename = ""
	elseif command == "stat" then
		print_status()
	elseif command == "save" then
		save_file()
	elseif command == "load" then
		load_file()
	elseif command == "rln" then
		local ln = tonumber(param)
		if ln then
			remove_line(math.floor(ln))
		else
			print("SYNTAX ERROR! Missing parameter")
		end
	else
		print("SYNTAX ERROR! Unrecognised Command "..command.."!")
	end
end
