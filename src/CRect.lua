

local CRect = class("CRect")

function CRect:ctor(_x, _y, _width, _height)
	self.x = _x; self.y = _y; self.width = _width; self.height = _height
end

function CRect:containsPoint(point)
	return cc.rectContainsPoint(cc.rect(self.x, self.y, self.width, self.height), point)
end

function CRect:getMinX()
	return cc.rectGetMinX(cc.rect(self.x, self.y, self.width, self.height))
end

function CRect:getMinY()
	return cc.rectGetMinY(cc.rect(self.x, self.y, self.width, self.height))
end



return CRect