local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
"                        .,,cc,,,.                                     ",
"                   ,c$$$$$$$$$$$$cc,                                  ",
"                ,c$$$$$$$$$$??\"\"??$?? ..                            ",
"             ,z$$$$$$$$$$$P xdMMbx  nMMMMMb                           ",
"            r\")$$$$??$$$$\" dMMMMMMb \"MMMMMMb                       ",
"          r\",d$$$$$>;$$$$ dMMMMMMMMb MMMMMMM.                        ",
"         d'z$$$$$$$>'\"\"\"\" 4MMMMMMMMM MMMMMMM>                     ",
"        d'z$$$$$$$$h $$$$r`MMMMMMMMM \"MMMMMM                         ",
"        P $$$$$$$$$$.`$$$$.'\"MMMMMP',c,\"\"\"'..                     ",
"       d',$$$$$$$$$$$.`$$$$$c,`\"\"_,c$$$$$$$$h                       ",
"       $ $$$$$$$$$$$$$.`$$$$$$$$$$$\"     \"$$$h                      ",
"      ,$ $$$$$$$$$$$$$$ $$$$$$$$$$%       `$$$L                       ",
"      d$c`?$$$$$$$$$$P'z$$$$$$$$$$c       ,$$$$.                      ",
"      $$$cc,\"\"\"\"\"\"\"\".zd$$$$$$$$$$$$c,  .,c$$$$$F              ",
"     ,$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                      ",
"     d$$$$$$$$$$$$$$$$c`?$$$$$$$$$$$$$$$$$$$$$$$                      ",
"     ?$$$$$$$$$.\"$$$$$$c,`..`?$$$$$$$$$$$$$$$$$$.                    ",
"     <$$$$$$$$$$. ?$$$$$$$$$h $$$$$$$$$$$$$$$$$$>                     ",
"      $$$$$$$$$$$h.\"$$$$$$$$P $$$$$$$$$$$$$$$$$$>                    ",
"      `$$$$$$$$$$$$ $$$$$$$\",d$$$$$$$$$$$$$$$$$$>                    ",
"       $$$$$$$$$$$$c`\"\"\"\"',c$$$$$$$$$$$$$$$$$$$$'                 ",
"       \"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$F                     ",
"        \"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'                      ",
"        .\"?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$P'  FOR FUCK'S SAKE!     ",
"     ,c$$c,`?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\"  THE TIME HE WASTES     ",
"   z$$$$$P\"   \"\"??$$$$$$$$$$$$$$$$$$$$$$$\"  IN RICING NVIM IS     ",
",c$$$$$P\"          .`\"\"????????$$$$$$$$$$c  DRIVING ME CRAZY.      ",
"`\"\"\"              ,$$$L.        \"?$$$$$$$$$.   WHAT'S THE MATTER  ",
"               ,cd$$$$$$$$$hc,    ?$$$$$$$$$c    WITH HIM ??????      ",
"              `$$$$$$$$$$$$$$$.    ?$$$$$$$$$h                        ",
"               `?$$$$$$$$$$$$P      ?$$$$$$$$$                        ",
"                 `?$$$$$$$$$P        ?$$$$$$$$$$$$hc                  ",
"                   \"?$$$$$$\"         <$$$$$$$$$$$$$$r   FUCKING     ",
"                     `\"\"\"\"           <$$$$$$$$$$$$$$F   KILL IT   ",
"                                      $$$$$$$$$$$$$F                  ",
"                                      `?$$$$$$$$P\"                   ",
"                                        \"????\"\"                    ",
}

-- Set menu
dashboard.section.buttons.val = {
	dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
	--dashboard.button( "f", "  > Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
	dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
	dashboard.button( "s", "  > Settings" , ":e $HOME/.config/nvim/init.lua | :cd %:p:h | split . | wincmd k | pwd<CR>"),
	dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
}

-- Set footer
local handle = io.popen('fortune')
local fortune = handle:read("*a")
handle:close()
dashboard.section.footer.val = fortune

dashboard.config.opts.noautocmd = true

vim.cmd[[autocmd User AlphaReady echo 'ready']]

alpha.setup(dashboard.opts)
