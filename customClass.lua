local function mainSuper (self, parent, parentConstr, current, method, ...)
    --print(self, parent, current, method)
    if method == "constructor" then
        return parentConstr(current, ...)
    end
    if parent and parent[method] and type(parent[method]) == "function" then
        return parent[method](current, ...)
    elseif parent then
        return parent.super(current, method, ...)
    end
    error(string.format("%s ERR: Could not find method [%s] in parent %s",current,method,parent),3)
end

local function mainClass(name, pCls)
    local cls = {}              -- the actual class
    local parent = nil;
    local parentConstr = nil;
    -- make cls a child of pCls
    if pCls then
        parent = pCls.parent;
        parentConstr = pCls.constr;
    end

    --function cls:super(method, ...) -- needs work, stack overflow when doubling the calls
    --    return mainSuper(self, parent, parentConstr, cls, method, ...)
    --end

    local clsConstr = false     -- the custom constructor
    -- The custom __name hack
    local clsAddr = tostring(cls):gsub("table", "LuaClass<"..name..">")
    local canCallWithTbl = true -- Wether or not to allow first call data set
                                -- will be set to false upon setting a field or method
    local mt = {

        super = function(self, a, b, ...)
            if type(a) == "table" and type(b) == "string" then
                return mainSuper(cls, parent, parentConstr, a, b,...)
            elseif type(a) == "string" and type(b) == "table" then
                return mainSuper(cls, parent, parentConstr, b, a,...)
            end
            return "ERROR: Invalid super syntax"
        end,

        getParent = function()
            return tostring(parent)
        end,

        __call = function(self, ...)
            -- First fields set or construction of objects
            local args = {...}
            if canCallWithTbl and #args == 1 then
                for k,v in pairs(args[1]) do
                    if string.lower(k) == "constructor" and type(v) == "function" then
                        clsConstr = v
                    else
                        rawset(cls, k, v)
                    end
                end
                canCallWithTbl = false
                return cls
            else
                local inst = {}
                local instAddr = tostring(inst):gsub("table", "LuaObject<"..name..">")

                local mt = {
                    getParent = function()
                        return tostring(cls);
                    end,
                    __tostring = function(self)
                        if self == inst then return instAddr end
                        return "Unexpected Error in __tostring"
                    end,
                }
                setmetatable(mt, cls)
                cls.__index = cls
                setmetatable(inst, mt)
                mt.__index = mt

                if clsConstr then clsConstr(inst, ...) end
                return inst
            end
        end,

        __newindex = function(self, key, value)
            -- Slight hack to allow hidden constructor field, as well as setting canCallWithTbl false
            if self == cls then
                if key == "super" or key == "extends" then
                    print("ERROR: Can't overwrite [",key,"]!")
                    return self
                end
                if string.lower(key) == "constructor" and type(value) == "function" then
                    clsConstr = value
                else
                    rawset(self, key, value)
                end
                canCallWithTbl = false
                return self
            end
            rawset(self, key, value)
        end,

        extends = function(self, newName)
            -- Creates a new class derived from this one, with this one as parent
            return mainClass(newName, {parent = self, constr = clsConstr})
        end,

        __tostring = function(self)
            -- The custom __name hack
            if self == cls then return clsAddr end
            return "Unexpected Error in __tostring"
        end,
    }
    if parent then setmetatable(mt, parent); parent.__index = parent end
    setmetatable(cls, mt)
    mt.__index = mt
    return cls
end

function Class(name)
    return mainClass(name)
end
