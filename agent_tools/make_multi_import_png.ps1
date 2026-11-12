Add-Type -AssemblyName System.Drawing

$W = 1800; $H = 1092
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$bmp.SetResolution(192, 192)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$script:sf = New-Object System.Drawing.StringFormat([System.Drawing.StringFormat]::GenericTypographic)
$script:sf.FormatFlags = $script:sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
$script:fonts = @{}

function F($name, $size, $style) {
    $key = "$name|$size|$style"
    if (-not $script:fonts.ContainsKey($key)) {
        $script:fonts[$key] = New-Object System.Drawing.Font($name, $size, [System.Drawing.FontStyle]$style, [System.Drawing.GraphicsUnit]::Pixel)
    }
    $script:fonts[$key]
}
function Br($hex) { New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex)) }
function Pn($hex, $w) { New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), [single]$w) }

function RR($x, $y, $w, $h, $r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc([single]$x, [single]$y, [single]$d, [single]$d, 180, 90)
    $p.AddArc([single]($x + $w - $d), [single]$y, [single]$d, [single]$d, 270, 90)
    $p.AddArc([single]($x + $w - $d), [single]($y + $h - $d), [single]$d, [single]$d, 0, 90)
    $p.AddArc([single]$x, [single]($y + $h - $d), [single]$d, [single]$d, 90, 90)
    $p.CloseFigure()
    $p
}
function Panel($x, $y, $w, $h, $fill, $border, $r = 16) {
    $p = RR $x $y $w $h $r
    $b = Br $fill
    $g.FillPath($b, $p)
    if ($border) { $pen = Pn $border 2; $g.DrawPath($pen, $p); $pen.Dispose() }
    $b.Dispose(); $p.Dispose()
}
function T($s, $font, $color, $x, $y) {
    $b = Br $color
    $g.DrawString($s, $font, $b, [single]$x, [single]$y)
    $b.Dispose()
}
function TC($s, $font, $color, $x, $y) {
    $b = Br $color
    $g.DrawString($s, $font, $b, [single]$x, [single]$y, $script:sf)
    $b.Dispose()
}
function MW($s, $font) { $g.MeasureString($s, $font, [System.Drawing.PointF]::new(0, 0), $script:sf).Width }

$CODE_FG   = '#E6EDF3'
$CODE_KW   = '#C792EA'
$CODE_STR  = '#A5E075'
$CODE_ID   = '#56B6C2'
$RE        = [regex]'\b(from|import|as)\b|"[^"]*"|''[^'']*''|\b(math_tools|file_tools|add|sub|mul|sin|cos|tan|log|exp|sqrt|math|random|os|utils)\b'

function CodePanel($x, $y, $w, $lines, $size) {
    $lh = 36; $h = 30 + $lines.Count * $lh
    Panel $x $y $w $h '#0F172A' $null 12
    $mono = F 'Consolas' $size 'Regular'
    $fy = $y + 16
    foreach ($ln in $lines) {
        if ($ln.TrimStart().StartsWith('#')) {
            TC $ln $mono '#7C8B9E' ($x + 20) $fy
        } else {
            $cx = $x + 20; $pos = 0
            foreach ($m in $RE.Matches($ln)) {
                if ($m.Index -gt $pos) {
                    $seg = $ln.Substring($pos, $m.Index - $pos)
                    TC $seg $mono $CODE_FG $cx $fy
                    $cx += (MW $seg $mono)
                }
                $tok = $m.Value
                if ($m.Groups[1].Success) { $col = $CODE_KW }
                elseif ($tok.StartsWith('"') -or $tok.StartsWith("'")) { $col = $CODE_STR }
                else { $col = $CODE_ID }
                TC $tok $mono $col $cx $fy
                $cx += (MW $tok $mono)
                $pos = $m.Index + $m.Length
            }
            if ($pos -lt $ln.Length) { TC $ln.Substring($pos) $mono $CODE_FG $cx $fy }
        }
        $fy += $lh
    }
    return $h
}

function Badge($x, $y, $text, $bghex, $fghex) {
    $fm = F 'Microsoft YaHei UI' 17 'Bold'
    $bw = (MW $text $fm) + 20; $bh = 28
    $p = RR $x $y $bw $bh 8
    $b = Br $bghex; $g.FillPath($b, $p); $b.Dispose(); $p.Dispose()
    T $text $fm $fghex ($x + 10) ($y + 3)
}

function Card($x, $y, $w, $h, $num, $title, $sub, $lines, $accent, $tag, $note, $codeSize = 22) {
    Panel $x $y $w $h '#FFFFFF' '#E3E8F0'

    $b = Br $accent
    $g.FillEllipse($b, [single]($x + 24), [single]($y + 22), [single]38, [single]38)
    $b.Dispose()
    T $num (F 'Consolas' 21 'Bold') '#FFFFFF' ($x + 36) ($y + 28)

    $ft = F 'Microsoft YaHei UI' 26 'Bold'
    T $title $ft '#1E293B' ($x + 76) ($y + 20)
    if ($tag) {
        $bx = $x + 76 + (MW $title $ft) + 14
        if ($tag -eq '推荐') { Badge $bx ($y + 24) $tag '#DCFCE7' '#15803D' }
        else { Badge $bx ($y + 24) $tag '#E2E8F0' '#475569' }
    }
    T $sub (F 'Microsoft YaHei UI' 18 'Regular') '#64748B' ($x + 76) ($y + 56)

    CodePanel ($x + 24) ($y + 92) ($w - 48) $lines $codeSize | Out-Null
    T $note (F 'Microsoft YaHei UI' 18 'Regular') '#64748B' ($x + 26) ($y + $h - 40)
}

# ---------------- 背景 / 标题 ----------------
$bgb = Br '#F5F7FB'
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

T 'Python 一次导入多个模块 / 多个函数' (F 'Microsoft YaHei UI' 42 'Bold') '#1E293B' 42 30
T 'import 与 from … import 的区别 · 写一行还是分行写 · 可读性建议' (F 'Microsoft YaHei UI' 20 'Regular') '#64748B' 44 88
$hl = Pn '#DCE3EE' 2
$g.DrawLine($hl, 40, 132, 1760, 132); $hl.Dispose()

# ---------------- ① import 多个模块 ----------------
$bar = Br '#3B82F6'
$g.FillRectangle($bar, 40, 156, 6, 30); $bar.Dispose()
T '① import 多个模块' (F 'Microsoft YaHei UI' 27 'Bold') '#1E293B' 58 152
T '一次把好几个模块都导进来，两种写法等价' (F 'Microsoft YaHei UI' 19 'Regular') '#64748B' 420 160

Card 40 200 845 286 '1' '分行写：一行一个' '最清晰，也是最常见的写法' @(
    'import math',
    'import random',
    'import os'
) '#3B82F6' '推荐' 'PEP8 风格；看 import 段就能知道依赖了什么'

Card 915 200 845 286 '2' '写一行：逗号分隔' '效果完全相同，只是更紧凑' @(
    'import math, random, os'
) '#64748B' '也可以' '模块一多就难一眼看清到底导入了哪些'

# ---------------- ② from … import 多个名字 ----------------
$bar2 = Br '#10B981'
$g.FillRectangle($bar2, 40, 520, 6, 30); $bar2.Dispose()
T '② from … import 多个名字' (F 'Microsoft YaHei UI' 27 'Bold') '#1E293B' 58 516
T '只从某个模块/包里拿出需要的几个名字' (F 'Microsoft YaHei UI' 19 'Regular') '#64748B' 470 524

Card 40  560 560 250 '3' '同一模块的多个函数' '标准库 math 里挑三个' @(
    'from math import sin, cos, sqrt'
) '#8B5CF6' $null '之后直接 sin(0)，不用写 math.sin' 21

Card 620 560 560 250 '4' '自定义包里的多个模块' 'utils 是一个包' @(
    'from utils import math_tools, file_tools'
) '#10B981' $null '前提：utils/ 下有 __init__.py' 20

Card 1200 560 560 250 '5' '自定义模块里的多个函数' '日常最常用的一种' @(
    'from utils.math_tools import add, sub, mul'
) '#F59E0B' $null '调用写 add(1, 2)，不用带模块前缀' 20

# ---------------- 建议条 ----------------
$sy = 846; $sh = 206
Panel 40 $sy 1720 $sh '#ECFDF5' '#A7F3D0'
$bar3 = Br '#10B981'
$g.FillRectangle($bar3, 40, $sy, 6, $sh); $bar3.Dispose()
T '建议' (F 'Microsoft YaHei UI' 26 'Bold') '#047857' 72 ($sy + 20)

T '· 模块 / 函数较多时，分行导入，一行一个，可读性最好' (F 'Microsoft YaHei UI' 21 'Regular') '#065F46' 72 ($sy + 74)
T '· 一行实在太长，可以用圆括号折行 —— 这是 PEP8 允许的写法' (F 'Microsoft YaHei UI' 21 'Regular') '#065F46' 72 ($sy + 116)
T '· 自定义模块导入失败时，先查 sys.path 里有没有它的目录' (F 'Microsoft YaHei UI' 21 'Regular') '#065F46' 72 ($sy + 158)

CodePanel 1080 ($sy + 30) 640 @(
    '# 太长就这样折行',
    'from math import (sin, cos, sqrt,',
    '                  tan, log, exp)'
) 21 | Out-Null

$out = 'D:\Data\Vscode\Demo_Project\python_multi_import.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "SAVED $out"
