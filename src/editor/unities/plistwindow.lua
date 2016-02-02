local M = {}
local EditBoxLite = require("common.EditBoxLite")
function M:create(  )
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.Layer = cc.Layer:create()

	local bg = cc.Sprite:create("MapA0001Bg.png")
	this.Layer:addChild(bg)
	--"#SaveMapButton.png",
    --        imageSelected = "#SaveMapButtonSelected.png"


    local packageEditbox = EditBoxLite.create({
        image = "#ButtonNormal.png",
        size = cc.size(display.width-250, 40),
        x = 40,
        y = display.top - 220,
    })
    packageEditbox:setAnchorPoint(0,0)
    this.Layer:addChild(packageEditbox)

    local line1 = self:createLabelAndEditLineAndButton("writablePath", "WritablePath:", "$(PROJDIR)/", "Select ...",
        function()
            local filedialog = PlayerProtocol:getInstance():getFileDialogService()
            local directory = filedialog:openDirectory("Choose Writeable directory", "")
            if string.len(directory) > 0 then
                self.writablePath:setText(directory)
                display.addSpriteFrames("Windows_Public.plist", "Windows_Public.png")
                display.addSpriteFrames("Hero_Public.plist","Hero_Public.png")
                local data = self:readPlist(directory.."\\Hero_Public.plist")
                this.scroll = KNScrollView:new( 30,0, 480, display.height - 100, 2,true)
                this.scroll.onItemSelected = handler(this,this.onIconClick)
                this.Layer:addChild(this.scroll:getLayer())
                for k,v in pairs(data) do
                	print("addddddddd=",k)
                	
                	this:initIcon(k,v)
                	
                end
                this.data = data
            end
        end)
        --:pos(0, display.top - 180)
        --:addTo(this.Layer)
       line1:setPosition(100,0)
       line1:setAnchorPoint(0,0)
       this.Layer:addChild(line1)
	return this
end
function M:onIconClick( position )
	local count =1
	for k,v in pairs(self.data) do
		if count == position then
			print("icon name=",k)
		end
		count  = count + 1
	end
	print("M:onIconClick")
end
function M:initIcon( key,data )

	local bg = display.newSprite("#Hero_List_Bg_None.png")
	local sp = display.newSprite("#"..key)
	--sp:setPosition()
	bg:addChild(sp)
	local content = sp:getContentSize()
    sp:setScale(80/content.width)
    sp:setPosition(cc.p(40,40))
	cc.ui.UILabel.new({
        UILabelType = 2,
        text = key,
        size = 20,
        color = display.COLOR_WHITE,
        })
    :pos(0, content.height)
    :addTo(sp)
   	self.scroll:addChild(bg,bg)	
	
end
function M:readPlist( path )
	print(path)
	--local data = io.open(path , "r")
	--local str  = data:read("*a")
	--data:close()
	local valueMap = cc.FileUtils:getInstance():getValueMapFromFile(path)
	for k,v in pairs(valueMap) do
		print(k,v)
		if k=="frames" then
			-- for element,value in pairs(v) do
			-- 	print(element,value)
			-- end
			return v
		end
	end
	
	
end
function M:createLabelAndEditLineAndButton(holder, labelString, editLineString, buttonString, listener)
    local node = display.newNode()

    -- label:
    cc.ui.UILabel.new({
        UILabelType = 2,
        text = labelString,
        size = fontSize,
        color = display.COLOR_WHITE,
        })
    :pos(40, display.top - 55)
    :addTo(node)

    -- edit line
    local locationEditbox = EditBoxLite.create({
        image = "#ButtonNormal.png",
        size = cc.size(display.width-250, 40),
        x = 40,
        y = display.top - 120,
    })
    locationEditbox:setAnchorPoint(0,0)
    locationEditbox:setText(editLineString)
    node:addChild(locationEditbox)

    -- button
    local selectButton = cc.ui.UIPushButton.new(images, {scale9 = true})
    selectButton:setAnchorPoint(0,0)
    selectButton:setButtonSize(150, 40)
    :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = buttonString,
            size = fontSize,
        }))
    :pos(display.right - 170, display.top - 120)
    :addTo(node)
    :onButtonClicked(listener)

    self[holder] = locationEditbox
    return node
end
function M:getLayer( )
	return self.Layer
end
--[[
void SpriteFrameCache::addSpriteFramesWithDictionary(ValueMap& dictionary, Texture2D* texture)
{
    /*
    Supported Zwoptex Formats:

    ZWTCoordinatesFormatOptionXMLLegacy = 0, // Flash Version
    ZWTCoordinatesFormatOptionXML1_0 = 1, // Desktop Version 0.0 - 0.4b
    ZWTCoordinatesFormatOptionXML1_1 = 2, // Desktop Version 1.0.0 - 1.0.1
    ZWTCoordinatesFormatOptionXML1_2 = 3, // Desktop Version 1.0.2+
    */

    
    ValueMap& framesDict = dictionary["frames"].asValueMap();
    int format = 0;

    // get the format
    if (dictionary.find("metadata") != dictionary.end())
    {
        ValueMap& metadataDict = dictionary["metadata"].asValueMap();
        format = metadataDict["format"].asInt();
    }

    // check the format
    CCASSERT(format >=0 && format <= 3, "format is not supported for SpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");

    for (auto iter = framesDict.begin(); iter != framesDict.end(); ++iter)
    {
        ValueMap& frameDict = iter->second.asValueMap();
        std::string spriteFrameName = iter->first;
        SpriteFrame* spriteFrame = _spriteFrames.at(spriteFrameName);
        if (spriteFrame)
        {
            continue;
        }
        
        if(format == 0) 
        {
            float x = frameDict["x"].asFloat();
            float y = frameDict["y"].asFloat();
            float w = frameDict["width"].asFloat();
            float h = frameDict["height"].asFloat();
            float ox = frameDict["offsetX"].asFloat();
            float oy = frameDict["offsetY"].asFloat();
            int ow = frameDict["originalWidth"].asInt();
            int oh = frameDict["originalHeight"].asInt();
            // check ow/oh
            if(!ow || !oh)
            {
                CCLOGWARN("cocos2d: WARNING: originalWidth/Height not found on the SpriteFrame. AnchorPoint won't work as expected. Regenrate the .plist");
            }
            // abs ow/oh
            ow = abs(ow);
            oh = abs(oh);
            // create frame
            spriteFrame = SpriteFrame::createWithTexture(texture,
                                                         Rect(x, y, w, h),
                                                         false,
                                                         Vec2(ox, oy),
                                                         Size((float)ow, (float)oh)
                                                         );
        } 
        else if(format == 1 || format == 2) 
        {
            Rect frame = RectFromString(frameDict["frame"].asString());
            bool rotated = false;

            // rotation
            if (format == 2)
            {
                rotated = frameDict["rotated"].asBool();
            }

            Vec2 offset = PointFromString(frameDict["offset"].asString());
            Size sourceSize = SizeFromString(frameDict["sourceSize"].asString());

            // create frame
            spriteFrame = SpriteFrame::createWithTexture(texture,
                                                         frame,
                                                         rotated,
                                                         offset,
                                                         sourceSize
                                                         );
        } 
        else if (format == 3)
        {
            // get values
            Size spriteSize = SizeFromString(frameDict["spriteSize"].asString());
            Vec2 spriteOffset = PointFromString(frameDict["spriteOffset"].asString());
            Size spriteSourceSize = SizeFromString(frameDict["spriteSourceSize"].asString());
            Rect textureRect = RectFromString(frameDict["textureRect"].asString());
            bool textureRotated = frameDict["textureRotated"].asBool();

            // get aliases
            ValueVector& aliases = frameDict["aliases"].asValueVector();

            for(const auto &value : aliases) {
                std::string oneAlias = value.asString();
                if (_spriteFramesAliases.find(oneAlias) != _spriteFramesAliases.end())
                {
                    CCLOGWARN("cocos2d: WARNING: an alias with name %s already exists", oneAlias.c_str());
                }

                _spriteFramesAliases[oneAlias] = Value(spriteFrameName);
            }
            
            // create frame
            spriteFrame = SpriteFrame::createWithTexture(texture,
                                                         Rect(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height),
                                                         textureRotated,
                                                         spriteOffset,
                                                         spriteSourceSize);
        }

        // add sprite frame
        _spriteFrames.insert(spriteFrameName, spriteFrame);
    }
}
]]
return M