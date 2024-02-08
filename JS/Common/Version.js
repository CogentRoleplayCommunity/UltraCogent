// CAUTION! The following line is updated by git hook(The patch number is incremented.). Don't forget to update the hook script if any of the names are changed.
// The patch value is read from the README.md file...
let Version = {MajorVersion: , MinorVersion: , Patch: 1};

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