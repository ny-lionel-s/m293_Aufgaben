Add-Type -AssemblyName System.Drawing

$OutputDir = Join-Path $PSScriptRoot 'images'
$MobileOutputDir = Join-Path $OutputDir 'mobile'
$TabletOutputDir = Join-Path $OutputDir 'tablet'
$DesktopOutputDir = Join-Path $OutputDir 'desktop'
New-Item -ItemType Directory -Force -Path $MobileOutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $TabletOutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $DesktopOutputDir | Out-Null

function New-Brush([string]$Hex) {
    [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($Hex))
}

function New-Pen([string]$Hex, [float]$Width = 2) {
    [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml($Hex), $Width)
}

function Draw-TextBlock {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [float]$Size = 16,
        [string]$Color = '#111111',
        [switch]$Bold,
        [string]$Align = 'near'
    )

    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = [System.Drawing.Font]::new('Segoe UI', $Size, $style)
    $brush = New-Brush $Color
    $format = [System.Drawing.StringFormat]::new()
    switch ($Align) {
        'center' { $format.Alignment = [System.Drawing.StringAlignment]::Center }
        'far' { $format.Alignment = [System.Drawing.StringAlignment]::Far }
        default { $format.Alignment = [System.Drawing.StringAlignment]::Near }
    }
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $rect = [System.Drawing.RectangleF]::new($X, $Y, $Width, $Height)
    $Graphics.DrawString($Text, $font, $brush, $rect, $format)
    $font.Dispose()
    $brush.Dispose()
    $format.Dispose()
}

function Draw-Box {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$Label = '',
        [string]$Fill = '#FFFFFF',
        [string]$Border = '#303030',
        [string]$TextColor = '#111111',
        [float]$FontSize = 16,
        [string]$Align = 'near',
        [switch]$Bold,
        [switch]$Dashed
    )

    $fillBrush = New-Brush $Fill
    $pen = New-Pen $Border 2
    if ($Dashed) {
        $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    }
    $Graphics.FillRectangle($fillBrush, $X, $Y, $Width, $Height)
    $Graphics.DrawRectangle($pen, $X, $Y, $Width, $Height)
    if ($Label) {
        Draw-TextBlock -Graphics $Graphics -Text $Label -X ($X + 12) -Y ($Y + 10) -Width ($Width - 24) -Height ($Height - 20) -Size $FontSize -Color $TextColor -Align $Align -Bold:$Bold
    }
    $fillBrush.Dispose()
    $pen.Dispose()
}

function Draw-CanvasTitle {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Title,
        [string]$Subtitle
    )

    Draw-TextBlock -Graphics $Graphics -Text $Title -X 32 -Y 18 -Width 1400 -Height 50 -Size 28 -Bold
    Draw-TextBlock -Graphics $Graphics -Text $Subtitle -X 34 -Y 64 -Width 1600 -Height 32 -Size 13 -Color '#5F6368'
}

function New-WireframeCanvas {
    param(
        [int]$Width,
        [int]$Height,
        [string]$Title,
        [string]$Subtitle
    )

    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#F4F1EA'))
    Draw-CanvasTitle -Graphics $graphics -Title $Title -Subtitle $Subtitle
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Save-Canvas {
    param(
        $Canvas,
        [string]$TargetDir,
        [string]$Filename
    )

    $path = Join-Path $TargetDir $Filename
    $Canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $Canvas.Graphics.Dispose()
    $Canvas.Bitmap.Dispose()
}

function Draw-ViewportFrame {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$Label
    )

    Draw-Box -Graphics $Graphics -X $X -Y $Y -Width $Width -Height $Height -Fill '#FCFCFC' -Border '#222222'
    Draw-TextBlock -Graphics $Graphics -Text $Label -X $X -Y ($Y + $Height - 34) -Width $Width -Height 24 -Size 11 -Align center -Color '#444444'
}

function Draw-Header {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [string]$Mode
    )

    $label = if ($Mode -eq 'mobile') {
        "Sticky Header`nLogo`nHome | Artikel | Kontakt"
    } else {
        'Sticky Header | Logo | Home | Artikel | Kontakt'
    }
    Draw-Box -Graphics $Graphics -X $X -Y $Y -Width $Width -Height 78 -Label $label -Fill '#204F2B' -Border '#222222' -TextColor '#FFFFFF' -FontSize 17 -Align center
}

function Draw-Footer {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$Mode
    )

    $label = if ($Mode -eq 'desktop') {
        'Footer | Ueber uns | Quick Links | Bleib dran | Copyright'
    } else {
        'Footer | Ueber uns | Links | Bleib dran | Copyright'
    }
    Draw-Box -Graphics $Graphics -X $X -Y $Y -Width $Width -Height $Height -Label $label -Fill '#252525' -Border '#222222' -TextColor '#FFFFFF' -FontSize 16 -Align center
}

function Draw-StartPage {
    param([string]$Device)

    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 820 -Height 2160 -Title 'Startseite Mobile' -Subtitle 'Aktuelle Site: Hero mit Info-Panel, Newsletter, Themenkarten und Artikel-Grid'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 410 -Height 1970 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 350 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 350 -Height 170 -Label "Hero Content`nEyebrow`nHeadline`nKurztext`n2 CTA Buttons" -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 440 -Width 350 -Height 200 -Label "Hero Panel`nIm Ueberblick`n3 Highlights`n3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 17
            Draw-Box -Graphics $g -X 100 -Y 660 -Width 350 -Height 125 -Label "Newsletter Section`nCopy`n[E-Mail-Adresse] [Abonnieren]" -Fill '#FFD9BF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 805 -Width 350 -Height 300 -Label "Themenbereich`nSection Heading`n6 Topic Cards untereinander`nBundesliga | Premier League | La Liga`nSerie A | Ligue 1 | Champions League" -Fill '#FFF4CC'
            Draw-Box -Graphics $g -X 100 -Y 1125 -Width 350 -Height 120 -Label "Artikelbereich Heading`nNeueste Artikel | Link zu allen Artikeln" -Fill '#EFEFEF'
            Draw-Box -Graphics $g -X 100 -Y 1260 -Width 350 -Height 180 -Label "Artikelkarte 1`nBild`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1455 -Width 350 -Height 180 -Label "Artikelkarte 2`nBild`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1650 -Width 350 -Height 180 -Label "Artikelkarte 3`nBild`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1845 -Width 350 -Height 190 -Mode mobile
            Save-Canvas -Canvas $c -TargetDir $MobileOutputDir -Filename 'Wireframe_Startseite_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1500 -Height 1460 -Title 'Startseite Tablet' -Subtitle 'Aktuelle Site: gestapelter Hero mit Panel, Newsletter, Themenraster und Artikelkarten'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1120 -Height 1265 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 1050 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 1050 -Height 145 -Label "Hero Content`nHeadline | Kurztext | 2 CTA Buttons" -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 95 -Y 420 -Width 1050 -Height 145 -Label "Hero Panel`nHighlights + Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 19
            Draw-Box -Graphics $g -X 95 -Y 585 -Width 1050 -Height 105 -Label "Newsletter Section`nCopy links | Formular rechts bzw. gestapelt" -Fill '#FFD9BF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 715 -Width 320 -Height 120 -Label 'Topic Card 1' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 460 -Y 715 -Width 320 -Height 120 -Label 'Topic Card 2' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 825 -Y 715 -Width 320 -Height 120 -Label 'Topic Card 3' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 855 -Width 320 -Height 120 -Label 'Topic Card 4' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 460 -Y 855 -Width 320 -Height 120 -Label 'Topic Card 5' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 825 -Y 855 -Width 320 -Height 120 -Label 'Topic Card 6' -Fill '#E6F0FF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 1010 -Width 505 -Height 180 -Label "Artikelkarte 1`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 640 -Y 1010 -Width 505 -Height 180 -Label "Artikelkarte 2`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 1210 -Width 505 -Height 100 -Label "Artikelkarte 3" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 640 -Y 1210 -Width 505 -Height 100 -Label "Artikelkarte 4" -Fill '#FFFFFF'
            Save-Canvas -Canvas $c -TargetDir $TabletOutputDir -Filename 'Wireframe_Startseite_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1900 -Height 1560 -Title 'Startseite Desktop' -Subtitle 'Aktuelle Site: zweispaltiger Hero, Newsletter, Themenkarten und 3-spaltiges Artikelraster'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1760 -Height 1390 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1680 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1080 -Height 210 -Label "Hero Content`nEyebrow`nHeadline`nEinleitung`n2 CTA Buttons" -Fill '#DCE8FA' -Align center -FontSize 24
            Draw-Box -Graphics $g -X 1210 -Y 255 -Width 570 -Height 210 -Label "Hero Panel`nIm Ueberblick`n3 Highlights`n3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 21
            Draw-Box -Graphics $g -X 100 -Y 490 -Width 1680 -Height 120 -Label "Newsletter Section`nCopy links | Formular rechts" -Fill '#FFD9BF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 635 -Width 1680 -Height 72 -Label 'Themen Heading | Waehle deine Liga oder gehe direkt zur Champions League' -Fill '#EFEFEF' -Align center -FontSize 18
            0..5 | ForEach-Object {
                $x = 100 + (($_ % 3) * 565)
                $y = 730 + ([math]::Floor($_ / 3) * 155)
                $fill = if ($_ -eq 5) { '#E6F0FF' } else { '#FFF4CC' }
                Draw-Box -Graphics $g -X $x -Y $y -Width 520 -Height 125 -Label ("Topic Card {0}`nIcon | Titel | Kurztext | Link" -f ($_ + 1)) -Fill $fill -Align center -FontSize 18
            }
            Draw-Box -Graphics $g -X 100 -Y 1065 -Width 1680 -Height 72 -Label 'Artikel Heading | Neueste Artikel | Link zu allen Artikeln' -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 1160 -Width 520 -Height 180 -Label "Artikelkarte 1`nBild`nKategorie | Titel | Kurztext | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 680 -Y 1160 -Width 520 -Height 180 -Label "Artikelkarte 2`nBild`nKategorie | Titel | Kurztext | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 1260 -Y 1160 -Width 520 -Height 180 -Label "Artikelkarte 3`nBild`nKategorie | Titel | Kurztext | Meta" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1365 -Width 1680 -Height 95 -Mode desktop
            Save-Canvas -Canvas $c -TargetDir $DesktopOutputDir -Filename 'Wireframe_Startseite_Desktop.png'
        }
    }
}

function Draw-ArticleListPage {
    param([string]$Device)

    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 820 -Height 2050 -Title 'Artikeluebersicht Mobile' -Subtitle 'Aktuelle Site: Hero mit Panel, Themenfilter und Artikelkarten in einer Spalte'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 410 -Height 1860 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 350 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 350 -Height 145 -Label "Hero Content`nAlle Artikel auf einen Blick`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 415 -Width 350 -Height 155 -Label "Hero Panel`nFilterbar`nHinweis + 3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 17
            Draw-Box -Graphics $g -X 100 -Y 590 -Width 350 -Height 155 -Label "Filterbereich`nHeading`n[Alle] [Bundesliga] [Premier League]`n[La Liga] [Serie A] [Ligue 1] [Champions League]" -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 765 -Width 350 -Height 110 -Label "Artikelgrid Heading`nAlle Beitraege | Link zur Startseite" -Fill '#EFEFEF'
            Draw-Box -Graphics $g -X 100 -Y 890 -Width 350 -Height 180 -Label "Artikelkarte 1`nBild`nKategorie`nTitel`nKurztext`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1085 -Width 350 -Height 180 -Label "Artikelkarte 2`nBild`nKategorie`nTitel`nKurztext`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1280 -Width 350 -Height 180 -Label "Artikelkarte 3`nBild`nKategorie`nTitel`nKurztext`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1475 -Width 350 -Height 180 -Label "Artikelkarte 4`nBild`nKategorie`nTitel`nKurztext`nMeta" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1670 -Width 350 -Height 255 -Mode mobile
            Save-Canvas -Canvas $c -TargetDir $MobileOutputDir -Filename 'Wireframe_Artikeluebersicht_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1500 -Height 1470 -Title 'Artikeluebersicht Tablet' -Subtitle 'Aktuelle Site: Hero mit Panel, Filterleiste und Artikelkarten in zwei Spalten'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1120 -Height 1275 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 1050 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 660 -Height 150 -Label "Hero Content`nAlle Artikel auf einen Blick`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 780 -Y 255 -Width 365 -Height 150 -Label "Hero Panel`nFilterbar`nHinweis + Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 430 -Width 1050 -Height 165 -Label "Filterbereich`nHeading`nAlle | Bundesliga | Premier League | La Liga | Serie A | Ligue 1 | Champions League" -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 620 -Width 1050 -Height 72 -Label 'Artikelgrid Heading | Alle Beitraege | Link zur Startseite' -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 720 -Width 505 -Height 190 -Label "Artikelkarte 1`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 640 -Y 720 -Width 505 -Height 190 -Label "Artikelkarte 2`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 930 -Width 505 -Height 190 -Label "Artikelkarte 3`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 640 -Y 930 -Width 505 -Height 190 -Label "Artikelkarte 4`nBild | Kategorie | Titel | Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 1140 -Width 505 -Height 140 -Label "Artikelkarte 5" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 640 -Y 1140 -Width 505 -Height 140 -Label "Artikelkarte 6" -Fill '#FFFFFF'
            Save-Canvas -Canvas $c -TargetDir $TabletOutputDir -Filename 'Wireframe_Artikeluebersicht_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1900 -Height 1500 -Title 'Artikeluebersicht Desktop' -Subtitle 'Aktuelle Site: zweispaltiger Hero, Filterleiste und grosses Kartenraster'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1760 -Height 1330 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1680 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1080 -Height 185 -Label "Hero Content`nAlle Artikel auf einen Blick`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 24
            Draw-Box -Graphics $g -X 1210 -Y 255 -Width 570 -Height 185 -Label "Hero Panel`nFilterbar`nHinweis + 3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 20
            Draw-Box -Graphics $g -X 100 -Y 470 -Width 1680 -Height 140 -Label "Filterbereich`nHeading + Beschreibung`nAlle | Bundesliga | Premier League | La Liga | Serie A | Ligue 1 | Champions League" -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 640 -Width 1680 -Height 72 -Label 'Artikelgrid Heading | Alle Beitraege im modernen Kartenlayout | Link zur Startseite' -Fill '#EFEFEF' -Align center -FontSize 18
            $positions = @(
                @{X=100;Y=735}, @{X=680;Y=735}, @{X=1260;Y=735},
                @{X=100;Y=950}, @{X=680;Y=950}, @{X=1260;Y=950}
            )
            for ($i = 0; $i -lt $positions.Count; $i++) {
                Draw-Box -Graphics $g -X $positions[$i].X -Y $positions[$i].Y -Width 520 -Height 190 -Label ("Artikelkarte {0}`nBild | Kategorie | Titel | Kurztext | Meta" -f ($i + 1)) -Fill '#FFFFFF'
            }
            Draw-Footer -Graphics $g -X 100 -Y 1170 -Width 1680 -Height 95 -Mode desktop
            Save-Canvas -Canvas $c -TargetDir $DesktopOutputDir -Filename 'Wireframe_Artikeluebersicht_Desktop.png'
        }
    }
}

function Draw-ArticleDetailPage {
    param([string]$Device)

    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 820 -Height 2360 -Title 'Artikeldetail Mobile' -Subtitle 'Aktuelle Site: Artikel-Header, Bild, Video, Text, Likes, Kommentare und Ruecklink'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 410 -Height 2170 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 350 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 350 -Height 190 -Label "Article Header`nThemenbadge`nTitel`nAutor-Foto | Name | Datum | Lesezeit" -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 465 -Width 350 -Height 180 -Label '[Artikelbild]' -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 665 -Width 350 -Height 150 -Label "Video Section`nUeberschrift`nEmbedded Video`nQuellenlink" -Fill '#F7F7F7' -Align center -Border '#666666' -Dashed
            Draw-Box -Graphics $g -X 100 -Y 835 -Width 350 -Height 500 -Label "Article Body`nEinleitung`nZwischenueberschriften`nmehrere Absaetze" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1355 -Width 350 -Height 300 -Label "Interaktionsbereich`nLike Button + Count`nKommentarformular`nName | Kommentar | Speichern`nKommentarliste" -Fill '#EAF4E3'
            Draw-Box -Graphics $g -X 100 -Y 1675 -Width 350 -Height 95 -Label '[Zurueck zu allen Artikeln]' -Fill '#EFEFEF' -Align center
            Draw-Footer -Graphics $g -X 100 -Y 1790 -Width 350 -Height 440 -Mode mobile
            Save-Canvas -Canvas $c -TargetDir $MobileOutputDir -Filename 'Wireframe_Artikeldetail_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1500 -Height 1660 -Title 'Artikeldetail Tablet' -Subtitle 'Aktuelle Site: breiter Artikel-Header, Medien, Interaktionen und Ruecklink'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1120 -Height 1470 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 1050 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 1050 -Height 180 -Label "Article Header`nThemenbadge | Titel | Autor-Foto | Name | Datum | Lesezeit" -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 95 -Y 460 -Width 1050 -Height 245 -Label '[Grosses Artikelbild]' -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 730 -Width 1050 -Height 165 -Label "Video Section`nUeberschrift | Embedded Video | Quellenlink" -Fill '#F7F7F7' -Border '#666666' -Dashed -Align center
            Draw-Box -Graphics $g -X 95 -Y 920 -Width 1050 -Height 210 -Label "Article Body`nEinleitung | Zwischenueberschriften | mehrere Absaetze" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 1155 -Width 1050 -Height 220 -Label "Interaktionsbereich`nKommentare & Likes`nLike Button | Kommentarformular | Kommentarliste" -Fill '#EAF4E3' -Align center -FontSize 19
            Draw-Box -Graphics $g -X 95 -Y 1400 -Width 1050 -Height 72 -Label '[Zurueck zu allen Artikeln]' -Fill '#EFEFEF' -Align center
            Save-Canvas -Canvas $c -TargetDir $TabletOutputDir -Filename 'Wireframe_Artikeldetail_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1900 -Height 1710 -Title 'Artikeldetail Desktop' -Subtitle 'Aktuelle Site: grosser Header, Medien, Interaktionen und Ruecklink unter dem Artikel'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1760 -Height 1540 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1680 -Mode desktop
            Draw-Box -Graphics $g -X 230 -Y 255 -Width 1420 -Height 210 -Label "Article Header`nThemenbadge`nGrosser Titel`nAutor-Foto | Name | Datum | Lesezeit" -Fill '#DCE8FA' -Align center -FontSize 24
            Draw-Box -Graphics $g -X 230 -Y 490 -Width 1420 -Height 285 -Label '[Grosses Artikelbild]' -Fill '#FFFFFF' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 230 -Y 800 -Width 1420 -Height 175 -Label "Video Section`nUeberschrift | Embedded Video | Quellenlink" -Fill '#F7F7F7' -Border '#666666' -Dashed -Align center -FontSize 20
            Draw-Box -Graphics $g -X 230 -Y 1000 -Width 1420 -Height 190 -Label "Article Body`nEinleitung | Zwischenueberschriften | mehrere Absaetze" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 230 -Y 1215 -Width 1420 -Height 220 -Label "Interaktionsbereich`nKommentare & Likes`nLike Button | Kommentarformular | Kommentarliste" -Fill '#EAF4E3' -Align center -FontSize 20
            Draw-Box -Graphics $g -X 680 -Y 1460 -Width 520 -Height 72 -Label '[Zurueck zu allen Artikeln]' -Fill '#EFEFEF' -Align center
            Draw-Footer -Graphics $g -X 100 -Y 1555 -Width 1680 -Height 95 -Mode desktop
            Save-Canvas -Canvas $c -TargetDir $DesktopOutputDir -Filename 'Wireframe_Artikeldetail_Desktop.png'
        }
    }
}

function Draw-ContactPage {
    param([string]$Device)

    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 820 -Height 2260 -Title 'Kontaktseite Mobile' -Subtitle 'Aktuelle Site: Hero mit Panel, Autorenkarten und Kontaktbereich mit Infopanel'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 410 -Height 2070 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 350 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 350 -Height 145 -Label "Hero Content`nUnser Team und dein direkter Draht zum Blog`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 415 -Width 350 -Height 155 -Label "Hero Panel`nKontaktpunkte`nHinweis + 3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 17
            Draw-Box -Graphics $g -X 100 -Y 590 -Width 350 -Height 105 -Label "Autor:innen Heading`nUnser Team hinter dem Fussball Blog" -Fill '#EFEFEF'
            Draw-Box -Graphics $g -X 100 -Y 710 -Width 350 -Height 130 -Label "Autor Card 1`nFoto | Name | Specialty | Kurzinfo" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 855 -Width 350 -Height 130 -Label "Autor Card 2`nFoto | Name | Specialty | Kurzinfo" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1000 -Width 350 -Height 130 -Label "Autor Card 3`nFoto | Name | Specialty | Kurzinfo" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1145 -Width 350 -Height 130 -Label "Autor Card 4`nFoto | Name | Specialty | Kurzinfo" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1290 -Width 350 -Height 130 -Label "Autor Card 5`nFoto | Name | Specialty | Kurzinfo" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1440 -Width 350 -Height 115 -Label "Formular Heading`nSchreib uns direkt ueber das Kontaktformular" -Fill '#EFEFEF'
            Draw-Box -Graphics $g -X 100 -Y 1570 -Width 350 -Height 160 -Label "Contact Panel`nAnfragen`n3 Hinweise / Punkte" -Fill '#EAF4E3' -Align center
            Draw-Box -Graphics $g -X 100 -Y 1745 -Width 350 -Height 215 -Label "Kontaktformular`n[Name]`n[E-Mail]`n[Betreff Dropdown]`n[Nachricht]`n[Senden]" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1975 -Width 350 -Height 160 -Mode mobile
            Save-Canvas -Canvas $c -TargetDir $MobileOutputDir -Filename 'Wireframe_Kontaktseite_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1500 -Height 1560 -Title 'Kontaktseite Tablet' -Subtitle 'Aktuelle Site: Hero mit Panel, Autorenraster und zweigeteilter Kontaktbereich'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1120 -Height 1365 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 1050 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 660 -Height 150 -Label "Hero Content`nUnser Team und dein direkter Draht zum Blog`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 780 -Y 255 -Width 365 -Height 150 -Label "Hero Panel`nKontaktpunkte`nHinweis + Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 430 -Width 1050 -Height 72 -Label 'Autor:innen Heading | Unser Team hinter dem Fussball Blog' -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 525 -Width 320 -Height 140 -Label "Autor Card 1" -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 460 -Y 525 -Width 320 -Height 140 -Label "Autor Card 2" -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 825 -Y 525 -Width 320 -Height 140 -Label "Autor Card 3" -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 685 -Width 320 -Height 140 -Label "Autor Card 4" -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 460 -Y 685 -Width 320 -Height 140 -Label "Autor Card 5" -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 855 -Width 1050 -Height 72 -Label 'Formular Heading | Schreib uns direkt ueber das Kontaktformular' -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 950 -Width 380 -Height 255 -Label "Contact Panel`nAnfragen`n3 Hinweise / Punkte" -Fill '#EAF4E3' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 505 -Y 950 -Width 640 -Height 255 -Label "Kontaktformular`nName | E-Mail | Betreff Dropdown | Nachricht | Senden" -Fill '#FFFFFF' -Align center -FontSize 18
            Draw-Footer -Graphics $g -X 95 -Y 1230 -Width 1050 -Height 105 -Mode tablet
            Save-Canvas -Canvas $c -TargetDir $TabletOutputDir -Filename 'Wireframe_Kontaktseite_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1900 -Height 1580 -Title 'Kontaktseite Desktop' -Subtitle 'Aktuelle Site: zweispaltiger Hero, Autorenraster und Kontaktlayout mit Panel plus Formular'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1760 -Height 1410 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1680 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1080 -Height 180 -Label "Hero Content`nUnser Team und dein direkter Draht zum Blog`nKurztext" -Fill '#DCE8FA' -Align center -FontSize 24
            Draw-Box -Graphics $g -X 1210 -Y 255 -Width 570 -Height 180 -Label "Hero Panel`nKontaktpunkte`nHinweis + 3 Stat-Boxen" -Fill '#EAF4E3' -Align center -FontSize 20
            Draw-Box -Graphics $g -X 100 -Y 465 -Width 1680 -Height 72 -Label 'Autor:innen Heading | Unser Team hinter dem Fussball Blog' -Fill '#EFEFEF' -Align center -FontSize 18
            for ($i = 0; $i -lt 5; $i++) {
                $x = 100 + ($i * 320)
                Draw-Box -Graphics $g -X $x -Y 560 -Width 270 -Height 190 -Label ("Autor Card {0}`nFoto | Name | Specialty | Kurzinfo" -f ($i + 1)) -Fill '#FFFFFF' -Align center
            }
            Draw-Box -Graphics $g -X 100 -Y 780 -Width 1680 -Height 72 -Label 'Formular Heading | Schreib uns direkt ueber das Kontaktformular' -Fill '#EFEFEF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 875 -Width 520 -Height 310 -Label "Contact Panel`nAnfragen`n3 Hinweise / Punkte" -Fill '#EAF4E3' -Align center -FontSize 20
            Draw-Box -Graphics $g -X 660 -Y 875 -Width 1120 -Height 310 -Label "Kontaktformular`nName | E-Mail | Betreff Dropdown | Nachricht | Senden" -Fill '#FFFFFF' -Align center -FontSize 20
            Draw-Footer -Graphics $g -X 100 -Y 1210 -Width 1680 -Height 95 -Mode desktop
            Save-Canvas -Canvas $c -TargetDir $DesktopOutputDir -Filename 'Wireframe_Kontaktseite_Desktop.png'
        }
    }
}

$devices = 'Mobile', 'Tablet', 'Desktop'
foreach ($device in $devices) {
    Draw-StartPage -Device $device
    Draw-ArticleListPage -Device $device
    Draw-ArticleDetailPage -Device $device
    Draw-ContactPage -Device $device
}

Write-Output 'Generated wireframes:'
Get-ChildItem $OutputDir -Recurse -Filter 'Wireframe_*.png' | Sort-Object FullName | Select-Object FullName, Length
