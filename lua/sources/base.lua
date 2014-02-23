if type(SOURCE) ~= 'table' then error('something went wrong') end -- Make sure we have a source

function SOURCE:Init() print('base source: init') end -- Called when source is loaded, either server or client side

function SOURCE:SV_Init() print('base source: init server') end -- Called when source is loaded server side 

function SOURCE:CL_Init() print('base source: init client') end -- Called when source is loaded client side

function SOURCE:Play() print('base source: play') end -- Called when round music should start

function SOURCE:Stop() print('base source: stop') end -- Called when round music should stop