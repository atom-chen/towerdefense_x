
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("res/")

require("config")
require("cocos.init")
require("framework.init")
require("utils")

require("editor.event.EventHandler")
local CRect = require("CRect")
function CCRectMake(_x,_y,_width,_height)
	return CRect.new(_x,_y,_width,_height)
end
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("res/hd")
display.addSpriteFrames("Images_hd.plist", "Images_hd.png")

display.addSpriteFrames("SheetMapBattle.plist", "SheetMapBattle.png")
display.addSpriteFrames("SheetEditor.plist", "SheetEditor.png")

--display.addSpriteFrames("")
display.replaceScene(require("editor.EditorScene").new())
-- local scene = display.newScene()
-- scene:addChild(require("editor.component.MapLayer").new())
-- display.replaceScene(scene)
