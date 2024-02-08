let Version = {MajorVersion: 0, MinorVersion: 0, Patch: 1};

function CheckVersion ()
{
    let StoredVersion = undefined;
    let StoredVersionJSON = GetCookieValue ('VersionCookie');

    if (StoredVersionJSON !== "" && StoredVersionJSON !== undefined)
    {
        try
        {
            StoredVersion = JSON.parse (StoredVersionJSON);
        }
        catch (error)
        {
            SetCookie ('VersionCookie', JSON.stringify (Version), 365);
        }
    }
    else
    {
        SetCookie ('VersionCookie', JSON.stringify (Version), 365);
        return;
    }

    if (StoredVersion)
        if (Version.MajorVersion > StoredVersion.MajorVersion || Version.MinorVersion > StoredVersion.MinorVersion || Version.Patch > StoredVersion.Patch)
        {
            //VersionHandler ();
            SetCookie ('VersionCookie', JSON.stringify (Version), 365);
        }
    else
        RefreshCookie ('VersionCookie', 365);
}