local Module = {}
for _, ModuleScript in ipairs( script:GetChildren() ) do
	print(ModuleScript.Name)
	Module[ModuleScript.Name] = require(ModuleScript)
end
return Module