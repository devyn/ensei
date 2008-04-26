# Ensei terminal language parser

def termEval(str)
	str.
		gsub(/\n/, ";\n").
		gsub(/open ?\[[^\[\]]\]/)     {|s| s.sub(/^open ?\[/, "openService(").sub(/\]$/, ")")         }.
		gsub(/new ?\[[^\[\]]\]/)      {|s| s.sub(/^new ?\[/, "newWindow(").sub(/\]$/, ")")            }.
		gsub(/refresh ?\[[^\[\]]\]/)  {|s| s.sub(/^refresh ?\[/, "refreshWindow(").sub(/\]$/, ")")    }.
		gsub(/move ?\[[^\[\]]\]/)     {|s| s.sub(/^move ?\[/, "moveWindow(").sub(/\]$/, ")")          }.
		gsub(/set ?\[[^\[\]]\]/)      {|s| s.sub(/^set ?\[/, "setContent(").sub(/\]$/, ")")           }.
		gsub(/get ?\[[^\[\]]\]/)      {|s| s.sub(/^get ?\[/, "getContent(").sub(/\]$/, ")")           }.
		gsub(/set ?\[[^\[\]]\]/)      {|s| s.sub(/^set ?\[/, "setContent(").sub(/\]$/, ")")           }.
		gsub(/title ?\[[^\[\]]\]/)    {|s| s.sub(/^title ?\[/, "setTitle(").sub(/\]$/, ")")           }.
		gsub(/close ?\[[^\[\]]\]/)    {|s| s.sub(/^close ?\[/, "closeWindow(").sub(/\]$/, ")")        }
end