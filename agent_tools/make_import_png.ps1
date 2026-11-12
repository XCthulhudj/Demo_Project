Add-Type -AssemblyName System.Drawing

$W = 1800; $H = 1256
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$bmp.SetResolution(192, 192)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$script:sf = New-Object System.Drawing.StringFormat([System.Drawing.StringFormat]::GenericTypographic)
# 关键: 不加这个标志, MeasureString 不计行尾空格, 会把 "import math_tools" 挤成 "importmath_tools"
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
# 代码用字宽精确的排版格式, 避免 token 拼接错位
function TC($s, $font, $color, $x, $y) {
    $b = Br $color
    $g.DrawString($s, $font, $b, [single]$x, [single]$y, $script:sf)
    $b.Dispose()
}
function MW($s, $font) { $g.MeasureString($s, $font, [System.Drawing.PointF]::new(0, 0), $script:sf).Width }

# ---------------- 背景 ----------------
$bgb = Br '#F5F7FB'
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

# ---------------- 标题 ----------------
T 'Python 跨目录导入自定义模块' (F 'Microsoft YaHei UI' 42 'Bold') '#1E293B' 42 32
T '三种常用方式 · 适用场景 · 发现不了模块时先看第三条' (F 'Microsoft YaHei UI' 20 'Regular') '#64748B' 44 90
$hl = Pn '#DCE3EE' 2
$g.DrawLine($hl, 40, 134, 1760, 134); $hl.Dispose()

# ================= 左列 =================
$lx = 40; $lw = 600

# ① 目录结构
Panel $lx 156 $lw 300 '#FFFFFF' '#E3E8F0'
T '① 项目目录结构' (F 'Microsoft YaHei UI' 25 'Bold') '#1E293B' ($lx + 26) 176

function Badge($x, $y, $text, $bghex, $fghex) {
    $fm = F 'Microsoft YaHei UI' 17 'Bold'
    $bw = (MW $text $fm) + 22; $bh = 30
    $p = RR $x $y $bw $bh 9
    $b = Br $bghex; $g.FillPath($b, $p); $b.Dispose(); $p.Dispose()
    T $text $fm $fghex ($x + 11) ($y + 4)
}

$mono = F 'Consolas' 24 'Regular'
$tree = @(
    @{ s = 'Demo_Project/';         c = '#1E293B'; b = '' },
    @{ s = '├── main.py';           c = '#334155'; b = '' },
    @{ s = '└── utils/';            c = '#3B82F6'; b = '包 package' },
    @{ s = '    ├── __init__.py';   c = '#F59E0B'; b = '必须有' },
    @{ s = '    └── math_tools.py'; c = '#334155'; b = '模块 module' }
)
$ty = 226
foreach ($row in $tree) {
    T $row.s $mono $row.c ($lx + 26) $ty
    if ($row.b) {
        if ($row.b -eq '包 package') { Badge ($lx + 322) ($ty + 2) $row.b '#DBEAFE' '#1D4ED8' }
        elseif ($row.b -eq '必须有') { Badge ($lx + 322) ($ty + 2) $row.b '#FEF3C7' '#B45309' }
        else { Badge ($lx + 322) ($ty + 2) $row.b '#E2E8F0' '#334155' }
    }
    $ty += 42
}

# ② 模块 vs 包
Panel $lx 476 $lw 250 '#FFFFFF' '#E3E8F0'
T '② 模块 与 包' (F 'Microsoft YaHei UI' 25 'Bold') '#1E293B' ($lx + 26) 496
T 'math_tools.py' (F 'Consolas' 22 'Regular') '#334155' ($lx + 26) 548
T '→  模块：一个 .py 文件' (F 'Microsoft YaHei UI' 20 'Regular') '#475569' ($lx + 240) 548
T 'utils/' (F 'Consolas' 22 'Regular') '#3B82F6' ($lx + 26) 594
T '→  包：一个文件夹' (F 'Microsoft YaHei UI' 20 'Regular') '#475569' ($lx + 240) 594
T '包里必须有 __init__.py（空文件也行）' (F 'Microsoft YaHei UI' 19 'Regular') '#64748B' ($lx + 26) 644
T 'Python 3.3+ 有隐式命名空间包，但作业/工程里建议显式写上' (F 'Microsoft YaHei UI' 17 'Regular') '#94A3B8' ($lx + 26) 676

# ③ 搜索机制
Panel $lx 746 $lw 264 '#FFFBEB' '#FDE68A'
T '③ 导入时到底发生了什么' (F 'Microsoft YaHei UI' 25 'Bold') '#92400E' ($lx + 26) 766
T '· 按 sys.path 列表的顺序逐项查找' (F 'Microsoft YaHei UI' 20 'Regular') '#78350F' ($lx + 26) 816
T '· sys.path[0] 通常是"运行脚本所在目录"' (F 'Microsoft YaHei UI' 20 'Regular') '#78350F' ($lx + 26) 856
T '· 全都找不到 → ModuleNotFoundError' (F 'Microsoft YaHei UI' 20 'Regular') '#78350F' ($lx + 26) 896
T '· 所以"别的目录里的模块"必须先进入 sys.path' (F 'Microsoft YaHei UI' 20 'Regular') '#78350F' ($lx + 26) 936

# ================= 右列 =================
$rx = 660; $rw = 1100

function Card($x, $y, $w, $num, $title, $sub, $lines, $accent, $tag) {
    $codeH = 30 + $lines.Count * 36
    $h = 100 + $codeH + 18
    Panel $x $y $w $h '#FFFFFF' '#E3E8F0'

    $b = Br $accent
    $g.FillEllipse($b, [single]($x + 24), [single]($y + 24), [single]40, [single]40)
    $b.Dispose()
    T $num (F 'Consolas' 22 'Bold') '#FFFFFF' ($x + 37) ($y + 30)

    $ft = F 'Microsoft YaHei UI' 27 'Bold'
    T $title $ft '#1E293B' ($x + 80) ($y + 21)
    if ($tag) {
        $fm = F 'Microsoft YaHei UI' 17 'Bold'
        $bx = $x + 80 + (MW $title $ft) + 16
        $p = RR $bx ($y + 27) ((MW $tag $fm) + 20) 28 9
        $bb = Br '#DCFCE7'; $g.FillPath($bb, $p); $bb.Dispose(); $p.Dispose()
        T $tag $fm '#15803D' ($bx + 10) ($y + 32)
    }
    T $sub (F 'Microsoft YaHei UI' 19 'Regular') '#64748B' ($x + 80) ($y + 60)

    $cy = $y + 100
    Panel ($x + 24) $cy ($w - 48) $codeH '#0F172A' $null 12

    $mono = F 'Consolas' 23 'Regular'
    $re = [regex]'\b(from|import|as)\b|"[^"]*"|''[^'']*''|\b(sys|print|math_tools|add)\b'
    $fy = $cy + 16
    foreach ($ln in $lines) {
        if ($ln.TrimStart().StartsWith('#')) {
            TC $ln $mono '#7C8B9E' ($x + 48) $fy
        } else {
            $cx = $x + 48; $pos = 0
            foreach ($m in $re.Matches($ln)) {
                if ($m.Index -gt $pos) {
                    $seg = $ln.Substring($pos, $m.Index - $pos)
                    TC $seg $mono '#E6EDF3' $cx $fy
                    $cx += (MW $seg $mono)
                }
                $tok = $m.Value
                if ($m.Groups[1].Success) { $col = '#C792EA' }
                elseif ($tok.StartsWith('"') -or $tok.StartsWith("'")) { $col = '#A5E075' }
                else { $col = '#56B6C2' }
                TC $tok $mono $col $cx $fy
                $cx += (MW $tok $mono)
                $pos = $m.Index + $m.Length
            }
            if ($pos -lt $ln.Length) {
                TC $ln.Substring($pos) $mono '#E6EDF3' $cx $fy
            }
        }
        $fy += 36
    }
    return $h
}

$y1 = 156
$h1 = Card $rx $y1 $rw '1' '同一目录：直接 import' '适合单个小工具、临时脚本' @(
    'import math_tools',
    'print(math_tools.add(1, 2))'
) '#3B82F6' $null

$y2 = $y1 + $h1 + 26
$h2 = Card $rx $y2 $rw '2' '子目录（包）：from 包 import 模块' '工程里最常用，推荐写法' @(
    'from utils import math_tools        # 导入模块',
    'print(math_tools.add(1, 2))',
    '',
    'from utils.math_tools import add    # 直接导入函数',
    'print(add(1, 2))'
) '#10B981' '推荐'

$y3 = $y2 + $h2 + 26
$h3 = Card $rx $y3 $rw '3' '任意目录：sys.path.append' '模块完全不在项目目录下时才用' @(
    'import sys',
    'sys.path.append(r"D:\MyModules")   # 加入搜索路径',
    'import math_tools'
) '#F59E0B' $null

# ================= 总结条 =================
$sy = $y3 + $h3 + 26
$sh = 172
Panel 40 $sy 1720 $sh '#EEF2FF' '#C7D2FE'
T '一句话总结' (F 'Microsoft YaHei UI' 25 'Bold') '#3730A3' 70 ($sy + 18)

$items = @(
    @{ k = '同一目录';  v = 'import 模块名' },
    @{ k = '子目录 / 包'; v = 'from 文件夹名 import 模块名' },
    @{ k = '其他目录';  v = 'sys.path.append(目录) 再 import' }
)
$colW = 1660 / 3
for ($i = 0; $i -lt 3; $i++) {
    $cx = 70 + $i * $colW
    Panel $cx ($sy + 62) ($colW - 34) 86 '#FFFFFF' '#DDE2F5' 12
    T $items[$i].k (F 'Microsoft YaHei UI' 19 'Bold') '#4338CA' ($cx + 20) ($sy + 74)
    T $items[$i].v (F 'Consolas' 21 'Regular') '#1E293B' ($cx + 20) ($sy + 106)
}

$out = 'D:\Data\Vscode\Demo_Project\python_import_modules.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "SAVED $out"
