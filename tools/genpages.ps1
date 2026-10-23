# Generate a standalone, crawlable page for every project view in index.html: /projects/<slug>/index.html
# Re-run after editing a project in index.html. Also rewrites sitemap.xml.
$root = Split-Path -Parent $PSScriptRoot
$enc = New-Object Text.UTF8Encoding $false
$src = [IO.File]::ReadAllText("$root\index.html", $enc)
$skip = @('office')

function Between([string]$s, [string]$a, [string]$b) { $i = $s.IndexOf($a); if ($i -lt 0) { throw "missing $a" }; $j = $s.IndexOf($b, $i); $s.Substring($i, $j + $b.Length - $i) }
function Strip([string]$s) { ([regex]::Replace($s, '<[^>]+>', '')).Replace('&amp;', '&').Trim() -replace '\s+', ' ' }
function Attr([string]$s) { $s.Replace('&', '&amp;').Replace('"', '&quot;') }
function Rootify([string]$s) {
  $s = [regex]::Replace($s, '(src|srcset)="images/', '$1="/images/')
  $s = [regex]::Replace($s, 'href="#project-([a-z0-9-]+)"', 'href="/projects/$1/"')
  $s = [regex]::Replace($s, 'href="#', 'href="/#')
  $s
}

$css = Between $src '<style>' '</style>'
$fonts = ([regex]::Matches($src, '<link[^>]+fonts\.(googleapis|gstatic)[^>]*>') | % { $_.Value }) -join "`n"
$header = Rootify (Between $src '<header class="nav">' '</header>')
# mobile menu has nested divs: take everything up to the top-level closing </div>
$mi = $src.IndexOf('<div class="mobilemenu" id="mobileMenu" hidden>'); $mj = $src.IndexOf("`n</div>", $mi); $menu = Rootify ($src.Substring($mi, $mj + 7 - $mi))
$footer = Rootify (Between $src '<footer>' '</footer>')
$wa = Between $src '<a class="wa-fab"' '</a>'
$mo = $src.IndexOf('/* Motion layer'); $ms = $src.LastIndexOf('<script>', $mo); $motion = $src.Substring($ms, $src.IndexOf('</script>', $mo) + 9 - $ms)

$navjs = @'
<script>
(function(){
  var page = document.getElementById('page');
  var menu = document.getElementById('mobileMenu');
  document.getElementById('menuOpen').addEventListener('click', function(){ menu.hidden = false; });
  document.getElementById('menuClose').addEventListener('click', function(){ menu.hidden = true; });
  var btns = [document.getElementById('langToggle'), document.getElementById('langToggleMobile')];
  function setLang(lang){
    var en = lang === 'en';
    page.dir = en ? 'ltr' : 'rtl';
    page.querySelectorAll('.ar').forEach(function(el){ el.hidden = en; });
    page.querySelectorAll('.en').forEach(function(el){ el.hidden = !en; });
    btns.forEach(function(b){ if (b) b.textContent = en ? 'AR' : 'EN'; });
    try { localStorage.setItem('athar_lang', lang); } catch(e){}
  }
  var saved = 'ar'; try { saved = localStorage.getItem('athar_lang') || 'ar'; } catch(e){}
  setLang(saved);
  btns.forEach(function(b){ if (b) b.addEventListener('click', function(){ setLang(page.dir === 'rtl' ? 'en' : 'ar'); }); });
})();
</script>
'@

$urls = New-Object Collections.Generic.List[string]
$rx = [regex]'<!-- =+ PROJECT: [^\n]*-->\s*<section class="view" id="view-project-([a-z0-9-]+)" hidden>'
foreach ($m in $rx.Matches($src)) {
  $slug = $m.Groups[1].Value; if ($skip -contains $slug) { continue }
  $start = $src.IndexOf('<section class="view"', $m.Index)
  $end = $src.IndexOf("`n<!-- ====", $start + 10)
  $view = $src.Substring($start, $end - $start).TrimEnd()
  $view = $view.Replace(" id=`"view-project-$slug`" hidden>", " id=`"view-project-$slug`">")
  $view = Rootify $view
  $h1 = [regex]::Match($view, '<h1><span class="ar">(.*?)</span>').Groups[1].Value
  $h1en = [regex]::Match($view, '<h1>.*?<span class="en" hidden>(.*?)</span>').Groups[1].Value
  $lead = Strip ([regex]::Match($view, '<p class="lead">\s*<span class="ar">(.*?)</span>', 'Singleline').Groups[1].Value)
  if ($lead.Length -gt 155) { $lead = $lead.Substring(0, 152).TrimEnd() + '…' }
  $img = [regex]::Match($view, 'src="(/images/[^"]+)"').Groups[1].Value
  $title = "$(Strip $h1) | أثر المدماك — تصميم وتنفيذ في الرياض"
  $url = "https://atharbuild.com/projects/$slug/"
  $ld = @{ '@context' = 'https://schema.org'; '@type' = 'BreadcrumbList'; itemListElement = @(
      @{ '@type' = 'ListItem'; position = 1; name = 'أثر المدماك'; item = 'https://atharbuild.com/' },
      @{ '@type' = 'ListItem'; position = 2; name = (Strip $h1); item = $url }) } | ConvertTo-Json -Depth 5 -Compress
  $html = @"
<!doctype html>
<html lang="ar">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$(Attr $title)</title>
<meta name="description" content="$(Attr $lead)">
<link rel="canonical" href="$url">
<link rel="icon" type="image/png" href="/images/site/603319a82a.png">
<meta name="theme-color" content="#182824">
<meta property="og:type" content="article">
<meta property="og:site_name" content="أثر المدماك — ATHAR Al-Midmak">
<meta property="og:title" content="$(Attr $title)">
<meta property="og:description" content="$(Attr $lead)">
<meta property="og:url" content="$url">
<meta property="og:image" content="https://atharbuild.com$img">
<meta property="og:locale" content="ar_SA">
<meta name="twitter:card" content="summary_large_image">
<script type="application/ld+json">$ld</script>
$fonts
$css
</head>
<body>
<div class="page" dir="rtl" id="page">
$header
$menu
<main>
$view
</main>
$footer
$wa
</div>
$navjs
$motion
</body>
</html>
"@
  New-Item -ItemType Directory -Force "$root\projects\$slug" | Out-Null
  [IO.File]::WriteAllText("$root\projects\$slug\index.html", $html, $enc)
  $urls.Add($url)
  "$slug | $(Strip $h1) | $h1en"
}
$today = Get-Date -Format 'yyyy-MM-dd'
$sm = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n  <url><loc>https://atharbuild.com/</loc><lastmod>$today</lastmod><priority>1.0</priority></url>`n"
foreach ($u in $urls) { $sm += "  <url><loc>$u</loc><lastmod>$today</lastmod><priority>0.8</priority></url>`n" }
$sm += "</urlset>`n"
[IO.File]::WriteAllText("$root\sitemap.xml", $sm, $enc)
"pages: $($urls.Count)"
