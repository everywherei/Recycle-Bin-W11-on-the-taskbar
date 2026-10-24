<#
.SYNOPSIS
  RecycleBinTray - Recycle Bin icon in the system tray, and hides the Recycle Bin from the desktop.

.DESCRIPTION
  Run without parameters to install and start. Use -Uninstall to remove it
  and bring the Recycle Bin back to the desktop.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\RecycleBinTray.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\RecycleBinTray.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$Tray   # uso interno: ejecuta el icono de bandeja
)

$ErrorActionPreference = 'Stop'
$AppName  = 'RecycleBinTray'
$RegApp   = "HKCU:\Software\$AppName"
$RunKey   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$InstDir  = Join-Path $env:LOCALAPPDATA $AppName
$InstFile = Join-Path $InstDir "$AppName.ps1"

# ---------------------------------------------------------------- idioma
$Strings = @{
    'en' = @{ Open='Open'; Empty='Empty Recycle Bin'; Props='Properties'; Exit='Exit'; TipEmpty='Recycle Bin: empty'; TipOne='Recycle Bin: 1 item'; TipMany='Recycle Bin: {0} items'; Installed='Installed. It starts with Windows and the Recycle Bin no longer appears on the desktop.'; Hint='If you do not see the icon, drag it from the tray overflow (^) to the taskbar.'; Uninstalled='Uninstalled. The Recycle Bin is back on the desktop.' }
    'es' = @{ Open='Abrir'; Empty='Vaciar papelera de reciclaje'; Props='Propiedades'; Exit='Salir'; TipEmpty='Papelera de reciclaje: vacía'; TipOne='Papelera de reciclaje: 1 elemento'; TipMany='Papelera de reciclaje: {0} elementos'; Installed='Instalado. Se inicia con Windows y la papelera ya no aparece en el escritorio.'; Hint='Si no ves el icono, arrástralo desde el desbordamiento (^) de la bandeja a la barra.'; Uninstalled='Desinstalado. La papelera vuelve a verse en el escritorio.' }
    'zh-cn' = @{ Open='打开'; Empty='清空回收站'; Props='属性'; Exit='退出'; TipEmpty='回收站：空'; TipOne='回收站：1 个项目'; TipMany='回收站：{0} 个项目'; Installed='安装完成。它将随 Windows 启动，回收站不再显示在桌面上。'; Hint='如果看不到图标，请将其从任务栏溢出区域 (^) 拖到任务栏。'; Uninstalled='已卸载。回收站已恢复显示在桌面上。' }
    'zh-tw' = @{ Open='開啟'; Empty='清除資源回收筒'; Props='內容'; Exit='結束'; TipEmpty='資源回收筒：空的'; TipOne='資源回收筒：1 個項目'; TipMany='資源回收筒：{0} 個項目'; Installed='安裝完成。它會隨 Windows 啟動，資源回收筒不再顯示於桌面。'; Hint='若看不到圖示，請將它從工作列溢位區 (^) 拖曳到工作列。'; Uninstalled='已解除安裝。資源回收筒已恢復顯示於桌面。' }
    'pt' = @{ Open='Abrir'; Empty='Esvaziar Lixeira'; Props='Propriedades'; Exit='Sair'; TipEmpty='Lixeira: vazia'; TipOne='Lixeira: 1 item'; TipMany='Lixeira: {0} itens'; Installed='Instalado. Inicia com o Windows e a Lixeira não aparece mais na área de trabalho.'; Hint='Se não vir o ícone, arraste-o do menu de ícones ocultos (^) para a barra de tarefas.'; Uninstalled='Desinstalado. A Lixeira voltou à área de trabalho.' }
    'ru' = @{ Open='Открыть'; Empty='Очистить корзину'; Props='Свойства'; Exit='Выход'; TipEmpty='Корзина: пуста'; TipOne='Корзина: 1 эл.'; TipMany='Корзина: {0} эл.'; Installed='Установлено. Запускается вместе с Windows, корзина больше не отображается на рабочем столе.'; Hint='Если значок не виден, перетащите его из скрытых значков (^) на панель задач.'; Uninstalled='Удалено. Корзина снова отображается на рабочем столе.' }
    'de' = @{ Open='Öffnen'; Empty='Papierkorb leeren'; Props='Eigenschaften'; Exit='Beenden'; TipEmpty='Papierkorb: leer'; TipOne='Papierkorb: 1 Element'; TipMany='Papierkorb: {0} Elemente'; Installed='Installiert. Startet mit Windows, der Papierkorb wird nicht mehr auf dem Desktop angezeigt.'; Hint='Wenn Sie das Symbol nicht sehen, ziehen Sie es aus dem Überlaufbereich (^) in die Taskleiste.'; Uninstalled='Deinstalliert. Der Papierkorb ist wieder auf dem Desktop sichtbar.' }
    'fr' = @{ Open='Ouvrir'; Empty='Vider la corbeille'; Props='Propriétés'; Exit='Quitter'; TipEmpty='Corbeille : vide'; TipOne='Corbeille : 1 élément'; TipMany='Corbeille : {0} éléments'; Installed='Installé. Démarre avec Windows et la corbeille n''apparaît plus sur le bureau.'; Hint='Si vous ne voyez pas l''icône, faites-la glisser depuis la zone de débordement (^) vers la barre des tâches.'; Uninstalled='Désinstallé. La corbeille est de nouveau visible sur le bureau.' }
    'ja' = @{ Open='開く'; Empty='ごみ箱を空にする'; Props='プロパティ'; Exit='終了'; TipEmpty='ごみ箱: 空'; TipOne='ごみ箱: 1 個の項目'; TipMany='ごみ箱: {0} 個の項目'; Installed='インストールしました。Windows と共に起動し、ごみ箱はデスクトップに表示されなくなります。'; Hint='アイコンが見えない場合は、通知領域のオーバーフロー (^) からタスクバーへドラッグしてください。'; Uninstalled='アンインストールしました。ごみ箱がデスクトップに戻りました。' }
    'it' = @{ Open='Apri'; Empty='Svuota Cestino'; Props='Proprietà'; Exit='Esci'; TipEmpty='Cestino: vuoto'; TipOne='Cestino: 1 elemento'; TipMany='Cestino: {0} elementi'; Installed='Installato. Si avvia con Windows e il Cestino non appare più sul desktop.'; Hint='Se non vedi l''icona, trascinala dall''area di overflow (^) alla barra delle applicazioni.'; Uninstalled='Disinstallato. Il Cestino è di nuovo sul desktop.' }
    'ko' = @{ Open='열기'; Empty='휴지통 비우기'; Props='속성'; Exit='끝내기'; TipEmpty='휴지통: 비어 있음'; TipOne='휴지통: 항목 1개'; TipMany='휴지통: 항목 {0}개'; Installed='설치되었습니다. Windows와 함께 시작되며 휴지통이 바탕 화면에 표시되지 않습니다.'; Hint='아이콘이 보이지 않으면 알림 영역 오버플로(^)에서 작업 표시줄로 끌어다 놓으세요.'; Uninstalled='제거되었습니다. 휴지통이 바탕 화면에 다시 표시됩니다.' }
}
$ui = [System.Globalization.CultureInfo]::CurrentUICulture.Name.ToLowerInvariant()
$code = if ($ui -match '^zh-(tw|hk|mo|hant)') { 'zh-tw' }
        elseif ($ui -like 'zh*') { 'zh-cn' }
        else { $ui.Split('-')[0] }
$T = if ($Strings.ContainsKey($code)) { $Strings[$code] } else { $Strings['en'] }

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

if (-not ('RecycleBinNative' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class RecycleBinNative
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    struct SHQUERYRBINFO { public uint cbSize; public long i64Size; public long i64NumItems; }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct SHSTOCKICONINFO
    {
        public uint cbSize; public IntPtr hIcon; public int iSysImageIndex; public int iIcon;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)] public string szPath;
    }

    [DllImport("shell32.dll", CharSet = CharSet.Unicode)] static extern int SHQueryRecycleBin(string root, ref SHQUERYRBINFO info);
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)] static extern int SHEmptyRecycleBin(IntPtr hwnd, string root, uint flags);
    [DllImport("shell32.dll")] static extern int SHGetStockIconInfo(int siid, uint flags, ref SHSTOCKICONINFO info);
    [DllImport("shell32.dll")] static extern void SHChangeNotify(int evt, uint flags, IntPtr a, IntPtr b);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)] static extern IntPtr LoadLibraryW(string name);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr LoadImageW(IntPtr hinst, IntPtr name, uint type, int cx, int cy, uint load);
    [DllImport("user32.dll")] static extern bool SetProcessDPIAware();
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr FindWindowW(string cls, string title);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr FindWindowExW(IntPtr parent, IntPtr after, string cls, string title);
    [DllImport("user32.dll")] static extern bool PostMessageW(IntPtr h, uint msg, IntPtr w, IntPtr l);

    public static void DpiAware() { try { SetProcessDPIAware(); } catch { } }

    public static long Count()
    {
        var i = new SHQUERYRBINFO();
        i.cbSize = (uint)Marshal.SizeOf(typeof(SHQUERYRBINFO));
        return SHQueryRecycleBin(null, ref i) == 0 ? i.i64NumItems : 0;
    }

    public static void Empty() { SHEmptyRecycleBin(IntPtr.Zero, null, 0); }

    // Icono oficial del sistema (mismo que usa Windows). SIID_RECYCLER=31, SIID_RECYCLERFULL=32
    public static IntPtr GetIcon(bool full, int size)
    {
        var i = new SHSTOCKICONINFO();
        i.cbSize = (uint)Marshal.SizeOf(typeof(SHSTOCKICONINFO));
        if (SHGetStockIconInfo(full ? 32 : 31, 0x101, ref i) == 0 && i.hIcon != IntPtr.Zero) return i.hIcon;
        // Respaldo: el método de Compactor (recursos 32/33 de shell32.dll)
        return LoadImageW(LoadLibraryW("shell32.dll"), (IntPtr)(full ? 33 : 32), 1, size, size, 0);
    }

    // Equivale a pulsar F5 en el escritorio
    public static void RefreshDesktop()
    {
        IntPtr view = FindWindowExW(FindWindowW("Progman", null), IntPtr.Zero, "SHELLDLL_DefView", null);
        if (view == IntPtr.Zero)
        {
            IntPtr w = IntPtr.Zero;
            while ((w = FindWindowExW(IntPtr.Zero, w, "WorkerW", null)) != IntPtr.Zero)
            {
                view = FindWindowExW(w, IntPtr.Zero, "SHELLDLL_DefView", null);
                if (view != IntPtr.Zero) break;
            }
        }
        if (view != IntPtr.Zero) PostMessageW(view, 0x111, (IntPtr)0x7103, IntPtr.Zero);
        SHChangeNotify(0x08000000, 0, IntPtr.Zero, IntPtr.Zero);
    }
}
'@
}

# ---------------------------------------------------------------- escritorio
function Set-DesktopRecycleBin {
    param([bool]$Hide)
    $guid = '{645FF040-5081-101B-9F08-00AA002F954E}'   # Recycle Bin
    foreach ($k in 'NewStartPanel', 'ClassicStartMenu') {
        $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\$k"
        if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
        Set-ItemProperty -Path $p -Name $guid -Value ([int]$Hide) -Type DWord
    }
    [RecycleBinNative]::RefreshDesktop()
}

function Remove-LegacyInstall {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.CommandLine -like '*PapeleraBandeja.ps1*-Tray*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Remove-ItemProperty -Path $RunKey -Name 'PapeleraBandeja' -ErrorAction SilentlyContinue
    Remove-Item 'HKCU:\Software\PapeleraBandeja' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $env:LOCALAPPDATA 'PapeleraBandeja') -Recurse -Force -ErrorAction SilentlyContinue
}

function Stop-TrayProcess {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
        Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like "*$AppName.ps1*-Tray*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------- bandeja
function Get-BinCount {
    $n = [RecycleBinNative]::Count()
    if ($n -gt 0) { return [int]$n }
    try {
        if (-not $script:shell) { $script:shell = New-Object -ComObject Shell.Application }
        return [int]$script:shell.NameSpace(10).Items().Count
    } catch { return 0 }
}

function Update-Tray {
    $n = Get-BinCount
    if ($n -ne $script:last) {
        $script:last = $n
        $script:ni.Icon = if ($n -gt 0) { $script:iconFull } else { $script:iconEmpty }
        $script:ni.Text = switch ($n) {
            0       { $T.TipEmpty }
            1       { $T.TipOne }
            default { [string]::Format($T.TipMany, $n) }
        }
    }
}
function Start-Tray {
    $created = $false
    $mutex = [System.Threading.Mutex]::new($true, "Local\$AppName", [ref]$created)
    if (-not $created) { return }

    [RecycleBinNative]::DpiAware()
    Set-DesktopRecycleBin $true

    $script:last = -1

    $size = [System.Windows.Forms.SystemInformation]::SmallIconSize.Width
    $script:iconEmpty = [System.Drawing.Icon]::FromHandle([RecycleBinNative]::GetIcon($false, $size))
    $script:iconFull  = [System.Drawing.Icon]::FromHandle([RecycleBinNative]::GetIcon($true,  $size))

    $script:ni = New-Object System.Windows.Forms.NotifyIcon
    $script:ni.Icon = $script:iconEmpty

    $menu    = New-Object System.Windows.Forms.ContextMenuStrip
    $miOpen  = $menu.Items.Add($T.Open)
    $miEmpty = $menu.Items.Add($T.Empty)
    $miProps = $menu.Items.Add($T.Props)
    [void]$menu.Items.Add('-')
    $miExit  = $menu.Items.Add($T.Exit)
    $miOpen.Font = New-Object System.Drawing.Font($menu.Font, [System.Drawing.FontStyle]::Bold)
    $script:ni.ContextMenuStrip = $menu
    $script:miEmpty = $miEmpty

    $script:openBin  = { Start-Process explorer.exe -ArgumentList 'shell:RecycleBinFolder' }
    $script:emptyBin = { [RecycleBinNative]::Empty(); Update-Tray }

    $miOpen.Add_Click($script:openBin)
    $menu.Add_Opening({
        $script:miEmpty.Enabled = ((Get-BinCount) -gt 0)
    })
    $miEmpty.Add_Click($script:emptyBin)
    $miProps.Add_Click({ (New-Object -ComObject Shell.Application).NameSpace(10).Self.InvokeVerb('properties') })
    $miExit.Add_Click({
        $script:ni.Visible = $false
        $script:ni.Dispose()
        [System.Windows.Forms.Application]::Exit()
    })
    $script:ni.Add_MouseUp({
        param($s, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left)   { & $script:openBin }
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Middle) { & $script:emptyBin }
    })

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1500
    $timer.Add_Tick({ Update-Tray })
    $timer.Start()

    Update-Tray
    $script:ni.Visible = $true
    Update-Tray
    [System.Windows.Forms.Application]::Run()
    $mutex.ReleaseMutex()
}

# ---------------------------------------------------------------- main
if ($Tray) {
    Start-Tray
}
elseif ($Uninstall) {
    Remove-LegacyInstall
    Stop-TrayProcess
    Remove-ItemProperty -Path $RunKey -Name $AppName -ErrorAction SilentlyContinue
    Remove-Item -Path $RegApp -Recurse -Force -ErrorAction SilentlyContinue
    Set-DesktopRecycleBin $false
    if ($PSCommandPath -ne $InstFile) { Remove-Item $InstDir -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host $T.Uninstalled
}
else {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideIcons -Value 0 -Type DWord
    [RecycleBinNative]::RefreshDesktop()
    New-Item -ItemType Directory -Path $InstDir -Force | Out-Null
    if ($PSCommandPath -ne $InstFile) { Copy-Item $PSCommandPath $InstFile -Force }
    $psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$InstFile"" -Tray"
    $vbs = Join-Path $InstDir "$AppName.vbs"
    Set-Content -Path $vbs -Encoding Unicode -Value ('CreateObject("WScript.Shell").Run "powershell.exe {0}", 0, False' -f $psArgs.Replace('"', '""'))
    Set-ItemProperty -Path $RunKey -Name $AppName -Value "wscript.exe `"$vbs`""
    Remove-LegacyInstall
    Stop-TrayProcess
    Start-Process wscript.exe -ArgumentList "`"$vbs`""
    Write-Host $T.Installed
    Write-Host $T.Hint
}
