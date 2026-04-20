Add-Type -AssemblyName System.Drawing

$OutputDir = Join-Path $PSScriptRoot 'images'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function New-Brush([string]$hex) {
    [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-Pen([string]$hex, [float]$width = 2) {
    [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
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

    Draw-TextBlock -Graphics $Graphics -Text $Title -X 32 -Y 18 -Width 1200 -Height 50 -Size 28 -Bold
    Draw-TextBlock -Graphics $Graphics -Text $Subtitle -X 34 -Y 64 -Width 1500 -Height 32 -Size 13 -Color '#5F6368'
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
        [string]$Filename
    )

    $path = Join-Path $OutputDir $Filename
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
    param([System.Drawing.Graphics]$Graphics,[int]$X,[int]$Y,[int]$Width,[string]$Mode)
    $label = if ($Mode -eq 'mobile') { "Header`nLogo`nMenu" } else { 'Header: Logo | Home | Artikel | Kontakt' }
    Draw-Box -Graphics $Graphics -X $X -Y $Y -Width $Width -Height 74 -Label $label -Fill '#2F6B31' -Border '#222222' -TextColor '#FFFFFF' -FontSize 17 -Align center
}

function Draw-Footer {
    param([System.Drawing.Graphics]$Graphics,[int]$X,[int]$Y,[int]$Width,[int]$Height,[string]$Mode)
    $label = if ($Mode -eq 'desktop') { 'Footer | Ueber uns | Quick Links | Social | Copyright' } else { 'Footer | Ueber uns | Links | Copyright' }
    Draw-Box -Graphics $Graphics -X $X -Y $Y -Width $Width -Height $Height -Label $label -Fill '#252525' -Border '#222222' -TextColor '#FFFFFF' -FontSize 16 -Align center
}

function Draw-StartPage {
    param([string]$Device)

    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 760 -Height 1780 -Title 'Startseite Mobile' -Subtitle 'Beliebte oder neuste Artikel, Themenuebersicht und Newsletter laut Projektauftrag'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 360 -Height 1590 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 300 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 245 -Width 300 -Height 150 -Label "Hero`nWillkommen beim Fussball Blog" -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 410 -Width 300 -Height 115 -Label "Newsletter`n[E-Mail-Adresse]`n[Abonnieren]" -Fill '#FFD9BF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 540 -Width 300 -Height 215 -Label "Themenuebersicht`nBundesliga`nPremier League`nLa Liga`nSerie A`nLigue 1`nChampions League" -Fill '#FFF4CC'
            Draw-Box -Graphics $g -X 100 -Y 770 -Width 300 -Height 215 -Label "Artikelkarte 1`n[Bild]`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1000 -Width 300 -Height 215 -Label "Artikelkarte 2`n[Bild]`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1230 -Width 300 -Height 215 -Label "Artikelkarte 3`n[Bild]`nKategorie`nTitel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1465 -Width 300 -Height 185 -Mode mobile
            Draw-Box -Graphics $g -X 470 -Y 190 -Width 230 -Height 280 -Label "Pflicht laut Auftrag`n- neuste/beliebte Artikel`n- Themenuebersicht`n- Newsletter-Anmeldung`n- Header, Main, Footer" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Startseite_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1420 -Height 1160 -Title 'Startseite Tablet' -Subtitle 'Responsive Zwischenansicht mit Grid fuer Themen und Artikel'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1040 -Height 960 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 970 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 250 -Width 970 -Height 140 -Label "Hero`nWillkommen beim Fussball Blog" -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 95 -Y 405 -Width 970 -Height 84 -Label 'Newsletter: [E-Mail-Adresse] [Abonnieren]' -Fill '#FFD9BF' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 510 -Width 300 -Height 130 -Label 'Thema 1' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 430 -Y 510 -Width 300 -Height 130 -Label 'Thema 2' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 765 -Y 510 -Width 300 -Height 130 -Label 'Thema 3' -Fill '#FFF4CC' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 95 -Y 660 -Width 470 -Height 180 -Label "Artikelkarte 1`n[Bild]  Titel  Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 660 -Width 470 -Height 180 -Label "Artikelkarte 2`n[Bild]  Titel  Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 860 -Width 470 -Height 140 -Label "Artikelkarte 3`n[Bild]  Titel  Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 860 -Width 470 -Height 140 -Label "Artikelkarte 4`n[Bild]  Titel  Meta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 1140 -Y 185 -Width 220 -Height 240 -Label "Tablet Fokus`n- horizontale Navigation`n- Themen im Grid`n- Artikel 2-spaltig" -Fill '#FFFFFF' -Border '#888888'
            Draw-Footer -Graphics $g -X 95 -Y 995 -Width 970 -Height 60 -Mode tablet
            Save-Canvas -Canvas $c -Filename 'Wireframe_Startseite_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1800 -Height 1300 -Title 'Startseite Desktop' -Subtitle 'Volles Layout mit Themenreihe, Artikel-Grid und Newsletter-Bereich'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1680 -Height 1140 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1600 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1600 -Height 145 -Label "Hero`nWillkommen beim Fussball Blog`nDie neuesten News aus den Top-Ligen" -Fill '#DCE8FA' -Align center -FontSize 24
            Draw-Box -Graphics $g -X 100 -Y 420 -Width 1600 -Height 90 -Label 'Newsletter: [E-Mail-Adresse] [Abonnieren]' -Fill '#FFD9BF' -Align center -FontSize 18
            0..5 | ForEach-Object {
                $x = 100 + ($_ * 265)
                $w = if ($_ -eq 5) { 275 } else { 235 }
                $label = @('Bundesliga','Premier League','La Liga','Serie A','Ligue 1','Champions League')[$_]
                Draw-Box -Graphics $g -X $x -Y 535 -Width $w -Height 88 -Label $label -Fill ($(if($_ -eq 5){'#E6F0FF'}else{'#FFF4CC'})) -Align center -FontSize 18
            }
            Draw-Box -Graphics $g -X 100 -Y 665 -Width 490 -Height 215 -Label "Artikelkarte 1`n[Bild]`nKategorie  Titel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 605 -Y 665 -Width 490 -Height 215 -Label "Artikelkarte 2`n[Bild]`nKategorie  Titel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 1110 -Y 665 -Width 490 -Height 215 -Label "Artikelkarte 3`n[Bild]`nKategorie  Titel`nKurztext`nAutor + Datum" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 900 -Width 490 -Height 175 -Label "Artikelkarte 4" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 605 -Y 900 -Width 490 -Height 175 -Label "Artikelkarte 5" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 1110 -Y 900 -Width 490 -Height 175 -Label "Artikelkarte 6" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1095 -Width 1600 -Height 105 -Mode desktop
            Save-Canvas -Canvas $c -Filename 'Wireframe_Startseite_Desktop.png'
        }
    }
}

function Draw-ArticleListPage {
    param([string]$Device)
    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 760 -Height 1560 -Title 'Artikeluebersicht Mobile' -Subtitle 'Themenseite mit allen Artikeln und Filter nach Thema'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 360 -Height 1370 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 300 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 245 -Width 300 -Height 95 -Label 'Hero: Alle Artikel' -Fill '#DCE8FA' -Align center -FontSize 18
            Draw-Box -Graphics $g -X 100 -Y 355 -Width 300 -Height 110 -Label "[Alle] [Bundesliga] [Premier]`n[La Liga] [Serie A] [Ligue 1] [UCL]" -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 485 -Width 300 -Height 190 -Label "Artikel 1`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 695 -Width 300 -Height 190 -Label "Artikel 2`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 905 -Width 300 -Height 190 -Label "Artikel 3`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1115 -Width 300 -Height 190 -Label "Artikel 4`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1325 -Width 300 -Height 115 -Mode mobile
            Draw-Box -Graphics $g -X 470 -Y 200 -Width 230 -Height 220 -Label "Pflicht`n- alle Artikel in Uebersicht`n- Themenfilter`n- Anzeige aller oder eines Themas" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeluebersicht_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1420 -Height 1120 -Title 'Artikeluebersicht Tablet' -Subtitle 'Filterleiste und 2-spaltiges Grid fuer die Themenseite'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1040 -Height 930 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 970 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 250 -Width 970 -Height 84 -Label 'Filterleiste: Alle | Bundesliga | Premier League | La Liga | Serie A | Ligue 1 | UCL' -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 360 -Width 470 -Height 205 -Label "Artikel 1`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 360 -Width 470 -Height 205 -Label "Artikel 2`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 590 -Width 470 -Height 205 -Label "Artikel 3`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 590 -Width 470 -Height 205 -Label "Artikel 4`n[Bild] Titel`nMeta" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 820 -Width 470 -Height 145 -Label "Artikel 5" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 820 -Width 470 -Height 145 -Label "Artikel 6" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 95 -Y 975 -Width 970 -Height 60 -Mode tablet
            Draw-Box -Graphics $g -X 1140 -Y 185 -Width 220 -Height 250 -Label "Auftrag`n- Themenseite mit allen Artikeln`n- filtern nach Thema`n- Grid-Layout fuer Inhalte" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeluebersicht_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1800 -Height 1260 -Title 'Artikeluebersicht Desktop' -Subtitle 'Volles Raster mit Themenfilter und vielen Artikeln'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1680 -Height 1100 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1600 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1600 -Height 78 -Label 'Filter: Alle | Bundesliga | Premier League | La Liga | Serie A | Ligue 1 | Champions League' -Fill '#EFEFEF' -Align center -FontSize 17
            $positions = @(
                @{X=100;Y=365}, @{X=615;Y=365}, @{X=1130;Y=365},
                @{X=100;Y=615}, @{X=615;Y=615}, @{X=1130;Y=615}
            )
            for ($i = 0; $i -lt $positions.Count; $i++) {
                Draw-Box -Graphics $g -X $positions[$i].X -Y $positions[$i].Y -Width 470 -Height 215 -Label ("Artikel {0}`n[Bild] Titel`nMeta" -f ($i + 1)) -Fill '#FFFFFF'
            }
            Draw-Footer -Graphics $g -X 100 -Y 865 -Width 1600 -Height 105 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 995 -Width 1600 -Height 180 -Label "Hinweis fuer Auftrag: Die Seite zeigt alle Artikel oder nur ein gewaehltes Thema. Die Karten sind im Grid organisiert und fuehren zu den Detailseiten." -Fill '#FFFFFF' -Border '#888888' -FontSize 18
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeluebersicht_Desktop.png'
        }
    }
}

function Draw-ArticleDetailPage {
    param([string]$Device)
    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 760 -Height 1820 -Title 'Artikeldetail Mobile' -Subtitle 'Artikel mit Thema, Bild, optionalem Video und Autorin/Autor'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 360 -Height 1630 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 300 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 245 -Width 300 -Height 50 -Label 'Themenbadge: Bundesliga' -Fill '#FFF4CC' -Align center
            Draw-Box -Graphics $g -X 100 -Y 310 -Width 300 -Height 95 -Label "Titel`nDer Klassiker: Bayern empfaengt Dortmund" -Fill '#FFFFFF' -FontSize 17 -Bold
            Draw-Box -Graphics $g -X 100 -Y 420 -Width 300 -Height 60 -Label 'Autor-Foto | Max Mueller | Datum | Lesezeit' -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 495 -Width 300 -Height 180 -Label '[Artikelbild]' -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 690 -Width 300 -Height 130 -Label "[Optionales Video]`nEmbed oder Platzhalter" -Fill '#F7F7F7' -Align center -Border '#666666' -Dashed
            Draw-Box -Graphics $g -X 100 -Y 835 -Width 300 -Height 405 -Label "Artikeltext`nEinleitung`nZwischenueberschrift`nAbsatz`nAbsatz`nAbsatz" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 1255 -Width 300 -Height 90 -Label '[Zurueck zu allen Artikeln]' -Fill '#EFEFEF' -Align center
            Draw-Footer -Graphics $g -X 100 -Y 1360 -Width 300 -Height 330 -Mode mobile
            Draw-Box -Graphics $g -X 470 -Y 220 -Width 230 -Height 260 -Label "Pflicht`n- Detailseite mit Artikel`n- Bild`n- evtl. Video`n- Autor:in + Thema" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeldetail_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1420 -Height 1260 -Title 'Artikeldetail Tablet' -Subtitle 'Detailansicht mit grossem Titelbereich und Medien untereinander'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1040 -Height 1070 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 970 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 180 -Height 48 -Label 'Thema: Bundesliga' -Fill '#FFF4CC' -Align center
            Draw-Box -Graphics $g -X 95 -Y 320 -Width 970 -Height 90 -Label 'Titel: Der Klassiker: Bayern empfaengt Dortmund' -Fill '#FFFFFF' -FontSize 22 -Bold -Align center
            Draw-Box -Graphics $g -X 95 -Y 425 -Width 970 -Height 56 -Label 'Autor-Foto | Max Mueller | 20. Maerz 2026 | 5 Min' -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 500 -Width 970 -Height 220 -Label '[Grosses Artikelbild]' -Fill '#FFFFFF' -Align center
            Draw-Box -Graphics $g -X 95 -Y 740 -Width 970 -Height 140 -Label '[Optionales Video / Embed]' -Fill '#F7F7F7' -Border '#666666' -Dashed -Align center
            Draw-Box -Graphics $g -X 95 -Y 900 -Width 970 -Height 170 -Label "Artikeltext`nEinleitung | Zwischenueberschriften | mehrere Absaetze" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 95 -Y 1080 -Width 970 -Height 70 -Mode tablet
            Draw-Box -Graphics $g -X 1140 -Y 220 -Width 220 -Height 240 -Label "Detailseite`n- Text, Bild, evtl. Video`n- Thema sichtbar`n- Autor mit Foto" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeldetail_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1800 -Height 1320 -Title 'Artikeldetail Desktop' -Subtitle 'Breite Lesespalte mit Titel, Medien und Metadaten'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1680 -Height 1160 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1600 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 200 -Height 46 -Label 'Bundesliga' -Fill '#FFF4CC' -Align center
            Draw-Box -Graphics $g -X 100 -Y 320 -Width 1200 -Height 85 -Label 'Der Klassiker: Bayern empfaengt Dortmund' -Fill '#FFFFFF' -FontSize 26 -Bold
            Draw-Box -Graphics $g -X 100 -Y 420 -Width 1200 -Height 56 -Label 'Autor-Foto | Max Mueller | 20. Maerz 2026 | 5 Min Lesezeit' -Fill '#EFEFEF' -Align center
            Draw-Box -Graphics $g -X 100 -Y 495 -Width 1200 -Height 260 -Label '[Artikelbild]' -Fill '#FFFFFF' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 100 -Y 775 -Width 1200 -Height 155 -Label '[Optionales Video / Embed]' -Fill '#F7F7F7' -Border '#666666' -Dashed -Align center
            Draw-Box -Graphics $g -X 100 -Y 950 -Width 1200 -Height 200 -Label "Artikeltext`nZwischenueberschriften`nAbsaetze mit Bild-/Video-Bezug" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 1350 -Y 320 -Width 310 -Height 260 -Label "Seiteninfo`n- Thema`n- Autor:in`n- Datum`n- Share / Navigation" -Fill '#FFFFFF' -Border '#888888'
            Draw-Box -Graphics $g -X 1350 -Y 605 -Width 310 -Height 160 -Label '[Zurueck zur Artikeluebersicht]' -Fill '#EFEFEF' -Align center
            Draw-Footer -Graphics $g -X 100 -Y 1170 -Width 1600 -Height 75 -Mode desktop
            Save-Canvas -Canvas $c -Filename 'Wireframe_Artikeldetail_Desktop.png'
        }
    }
}

function Draw-ContactPage {
    param([string]$Device)
    switch ($Device) {
        'Mobile' {
            $c = New-WireframeCanvas -Width 760 -Height 1760 -Title 'Kontaktseite Mobile' -Subtitle 'Autoreninformationen und Kontaktformular mit Betreffauswahl'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 70 -Y 110 -Width 360 -Height 1570 -Label 'SMARTPHONE VIEW'
            Draw-Header -Graphics $g -X 100 -Y 155 -Width 300 -Mode mobile
            Draw-Box -Graphics $g -X 100 -Y 245 -Width 300 -Height 85 -Label 'Hero: Kontakt' -Fill '#DCE8FA' -Align center
            Draw-Box -Graphics $g -X 100 -Y 345 -Width 300 -Height 140 -Label "Autor 1`n[Foto] Name | Rolle" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 500 -Width 300 -Height 140 -Label "Autor 2`n[Foto] Name | Rolle" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 655 -Width 300 -Height 140 -Label "Autor 3`n[Foto] Name | Rolle" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 100 -Y 810 -Width 300 -Height 355 -Label "Kontaktformular`n[Name]`n[E-Mail]`n[Betreff v]`n[Nachricht]`n[Senden]" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 100 -Y 1185 -Width 300 -Height 445 -Mode mobile
            Draw-Box -Graphics $g -X 470 -Y 210 -Width 230 -Height 220 -Label "Pflicht`n- Autoreninformationen`n- Kontaktformular`n- Dropdown fuer Betreff" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Kontaktseite_Mobile.png'
        }
        'Tablet' {
            $c = New-WireframeCanvas -Width 1420 -Height 1180 -Title 'Kontaktseite Tablet' -Subtitle 'Autoren im Grid und breites Formular fuer Rueckfragen zum Blog'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1040 -Height 990 -Label 'TABLET VIEW'
            Draw-Header -Graphics $g -X 95 -Y 160 -Width 970 -Mode tablet
            Draw-Box -Graphics $g -X 95 -Y 255 -Width 970 -Height 82 -Label 'Kontakt' -Fill '#DCE8FA' -Align center -FontSize 22
            Draw-Box -Graphics $g -X 95 -Y 360 -Width 230 -Height 145 -Label "Autor 1`n[Foto] Name" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 345 -Y 360 -Width 230 -Height 145 -Label "Autor 2`n[Foto] Name" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 595 -Y 360 -Width 230 -Height 145 -Label "Autor 3`n[Foto] Name" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 835 -Y 360 -Width 230 -Height 145 -Label "Autor 4`n[Foto] Name" -Fill '#FFFFFF'
            Draw-Box -Graphics $g -X 95 -Y 535 -Width 970 -Height 360 -Label "Kontaktformular`n[Name]`n[E-Mail]`n[Betreff Dropdown]`n[Nachricht]`n[Nachricht senden]" -Fill '#FFFFFF'
            Draw-Footer -Graphics $g -X 95 -Y 915 -Width 970 -Height 90 -Mode tablet
            Draw-Box -Graphics $g -X 1140 -Y 220 -Width 220 -Height 240 -Label "Kontaktseite`n- Autoren mit Foto`n- Formular fuer Fragen`n- Betreffauswahl per Dropdown" -Fill '#FFFFFF' -Border '#888888'
            Save-Canvas -Canvas $c -Filename 'Wireframe_Kontaktseite_Tablet.png'
        }
        'Desktop' {
            $c = New-WireframeCanvas -Width 1800 -Height 1280 -Title 'Kontaktseite Desktop' -Subtitle 'Teamdarstellung in mehreren Spalten und zentriertes Kontaktformular'
            $g = $c.Graphics
            Draw-ViewportFrame -Graphics $g -X 60 -Y 110 -Width 1680 -Height 1120 -Label 'DESKTOP VIEW'
            Draw-Header -Graphics $g -X 100 -Y 160 -Width 1600 -Mode desktop
            Draw-Box -Graphics $g -X 100 -Y 255 -Width 1600 -Height 84 -Label 'Kontakt' -Fill '#DCE8FA' -Align center -FontSize 24
            for ($i = 0; $i -lt 5; $i++) {
                $x = 100 + ($i * 315)
                Draw-Box -Graphics $g -X $x -Y 370 -Width 250 -Height 160 -Label ("Autor {0}`n[Foto] Name" -f ($i + 1)) -Fill '#FFFFFF' -Align center
            }
            Draw-Box -Graphics $g -X 390 -Y 575 -Width 1020 -Height 360 -Label "Kontaktformular`nName`nE-Mail`nBetreff Dropdown`nNachricht`nNachricht senden" -Fill '#FFFFFF' -Align center -FontSize 20
            Draw-Footer -Graphics $g -X 100 -Y 970 -Width 1600 -Height 175 -Mode desktop
            Save-Canvas -Canvas $c -Filename 'Wireframe_Kontaktseite_Desktop.png'
        }
    }
}

$devices = 'Mobile','Tablet','Desktop'
foreach ($device in $devices) {
    Draw-StartPage -Device $device
    Draw-ArticleListPage -Device $device
    Draw-ArticleDetailPage -Device $device
    Draw-ContactPage -Device $device
}

Write-Output 'Generated wireframes:'
Get-ChildItem $OutputDir -Filter 'Wireframe_*.png' | Sort-Object Name | Select-Object Name, Length
