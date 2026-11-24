function Search-RedditPatchTuesday {
    <#
    .SYNOPSIS
    Finds the /r/sysadmin Patch Tuesday megathread and collects every KB number
    mentioned in its comments.

    .NOTES
    Found the original on Reddit years ago. This version adds the missing closing
    brace (the old copy was unparsable), a User-Agent (Reddit blocks requests
    without a recognizable one), and a single de-duplicated KB regex.
    #>

    $userAgent = 'powershell:Search-RedditPatchTuesday:v2.0 (maintained locally)'

    # Get the r/sysadmin front page
    $posts = Invoke-RestMethod 'https://www.reddit.com/r/sysadmin/.json' -UserAgent $userAgent

    # Find the Patch Tuesday megathread
    $megathread = $posts.data.children.data |
        Where-Object { $_.title -like '*Patch Tuesday Megathread*' } |
        Select-Object -First 1

    if (-not $megathread) {
        Write-Warning 'No Patch Tuesday megathread found on the front page right now.'
        return
    }

    # Get the comments of the megathread
    $comments = Invoke-RestMethod "$($megathread.Url).json" -UserAgent $userAgent

    # Iterate through the comments and pick out every KB number (case-insensitive)
    foreach ($comment in $comments.data.children.data) {
        if (-not $comment.body) { continue }

        $kbs = [regex]::Matches($comment.body, '(?i)kb[\s-]?\d{6,7}') |
            ForEach-Object { $_.Value } |
            Sort-Object -Unique

        if ($kbs) {
            [PSCustomObject]@{
                UpVotes = $comment.ups
                KBs      = $kbs -join ', '
                Body     = $comment.body
            }
        }
    }
}
