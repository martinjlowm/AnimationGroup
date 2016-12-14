if not LibStub then return end

local Classy = LibStub('Classy-1.0')

LibAG = LibStub:NewLibrary('AnimationGroup-1.0', 0)
if not LibAG then return end

function LibAG:New(name, parent)
    self[name] = Classy:New('Frame', parent)

    return self[name]
end

local Region = LibAG:New('Region')

function Region:CreateAnimationGroup(name, inherits_from)
    local ag = LibAG.AnimationGroup:Bind(CreateFrame('Frame', nil))
    ag:SetParent(self)
    return ag
end

do
    local animation_handlers = {
        ['OnLoad'] = {},
        ['OnPlay'] = {},
        ['OnPaused'] = {},
        ['OnStop'] = {},
        ['OnFinished'] = {}
    }

    local _SetScript

    local function SetScript(self, handler, func)
        if animation_handlers[handler] then
            table.insert(animation_handlers[handler], { self, func })
        else
            _SetScript(self, handler, func)
        end
    end

    local _CreateFrame = CreateFrame
    function CreateFrame(...)
        local frame = _CreateFrame(unpack(arg))

        if not _SetScript then
            _SetScript = frame.SetScript
        end

        frame.SetScript = SetScript
        frame.CreateAnimationGroup = function()
            return LibAG.Region.CreateAnimationGroup(frame, nil, nil)
        end

        return frame
    end
end
