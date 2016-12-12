if not LibStub then return end

local Classy = LibStub('Classy-1.0')

local LibAG = LibStub:NewLibrary('AnimationGroup-1.0', 0)
if not LibAG then return end


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
    function CreateFrame(frame_type, name, parent, template)
        if string.lower(frame_type) == 'AnimationGroup' then
            local group = LibAG['AnimationGroup']
                .Bind(CreateFrame('Frame', name, parent, template))

            if not _SetScript then
                _SetScript = group.SetScript
            end

            group.SetScript = SetScript

            return group
        else
            return _CreateFrame(frame_type, name, parent, template)
        end
    end
end

function LibAG:New(name, module)
    self[name] = module or Classy:New('Frame')
    return self[name]
end
