-- data/lib/json.lua
-- Uma implementação simples e leve de JSON para Lua (Compatível com TFS 1.2 / Lua 5.2)

json = {}
local json_ext = {}

local table_concat = table.concat
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_sub = string.sub

local function escape_string(s)
    s = string_gsub(s, '([%c%b\\])', {
        ['"'] = '\\"', ['\\'] = '\\\\', ['/'] = '\\/',
        ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t',
        ['\b'] = '\\b', ['\f'] = '\\f'
    })
    return string_format('"%s"', s)
end

function json_ext.encode(v)
    local t = type(v)
    if t == 'nil' then
        return 'null'
    elseif t == 'number' then
        return tostring(v)
    elseif t == 'boolean' then
        return v and 'true' or 'false'
    elseif t == 'string' then
        return escape_string(v)
    elseif t == 'table' then
        if getmetatable(v) and getmetatable(v).__tostring then
            return escape_string(tostring(v))
        end
        
        local is_array = true
        local max = 0
        
        for k, _ in pairs(v) do
            if type(k) == 'number' and k > 0 and math.floor(k) == k then
                if k > max then max = k end
            else
                is_array = false
                break
            end
        end
        
        if is_array and max > 0 then
            local res = {}
            for i = 1, max do
                res[i] = json_ext.encode(v[i])
            end
            return string_format('[%s]', table_concat(res, ','))
        else
            local res = {}
            for k, val in pairs(v) do
                local key_type = type(k)
                if key_type == 'string' or key_type == 'number' then
                    local key = (key_type == 'number' and k or escape_string(k))
                    local encoded_val = json_ext.encode(val)
                    table_insert(res, string_format('%s:%s', key, encoded_val))
                end
            end
            return string_format('{%s}', table_concat(res, ','))
        end
    else
        return 'null' -- Tipos não suportados
    end
end

-- Simples parser JSON, apenas para o escopo de carregar o que foi salvo
local function parse_value(str)
    -- Simplificado: assumindo que a string salva é válida e não muito complexa
    local env = setmetatable({}, {__index = _G})
    local fn, err = load('return ' .. str, '=json_decode', 't', env)
    if not fn then
        error('JSON Decode Error: ' .. err)
    end
    local result = {pcall(fn)}
    if not result[1] then
        error('JSON Decode Runtime Error: ' .. result[2])
    end
    return result[2]
end

function json_ext.decode(str)
    -- O TFS 1.2 (ou Lua 5.2/5.3) permite esta técnica simples se a string JSON for limpa.
    local result, err = pcall(parse_value, str)
    if result then
        return err
    else
        print(string.format("[JSON] Falha ao decodificar JSON: %s", err))
        return nil
    end
end

json.encode = json_ext.encode
json.decode = json_ext.decode