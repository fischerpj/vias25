-- list-images.lua
-- Portable Quarto/Pandoc Lua filter (no external modules)

function Div(el)
  -- Only process blocks with class "list-images"
  if el.classes[1] ~= "list-images" then
    return nil
  end

  -- Read attributes
  local folder = el.attributes["folder"] or "Agdes25"
  local width  = el.attributes["width"] or "120"

  -- List files using Pandoc's built-in API
  local files = pandoc.system.list_directory(folder)

  -- Filter JPG/JPG files (case-insensitive)
  local rows = {}
  for _, file in ipairs(files) do
    local name, ext = pandoc.path.split_extension(file)
    ext = ext:lower():gsub("^%.", "")  -- remove leading dot
    if ext == "jpg" then
      local path = pandoc.path.join({folder, file})
      local thumb = string.format("![](%s){width=%s}", path, width)
      table.insert(rows, {file = file, thumb = thumb})
    end
  end

  -- Sort alphabetically
  table.sort(rows, function(a, b) return a.file < b.file end)

  -- Build Markdown table
  local md = {}
  table.insert(md, "| File | Thumbnail |")
  table.insert(md, "|------|-----------|")
  for _, r in ipairs(rows) do
    table.insert(md, string.format("| %s | %s |", r.file, r.thumb))
  end

  return pandoc.RawBlock("markdown", table.concat(md, "\n"))
end
