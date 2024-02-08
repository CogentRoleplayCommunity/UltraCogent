function SetCookie (Name, Value, ExpirationDate = undefined)
{
    if (Name !== undefined && Name !== "" && Value !== undefined && Value !== "")
        if (ExpirationDate)
        {
            let Expiry = new Date();
            if (ExpirationDate > 0)
            {
                Expiry.setTime (Expiry.getTime () + (ExpirationDate * 24 * 60 * 60 * 1000));
                Expiry = "expires=" + Expiry.toUTCString ();
            }
            document.cookie = Name + "=" + Value + ";" + Expiry + ";path=/;SameSite=Strict";
        }
        else
            document.cookie = Name + "=" + Value + ";SameSite=Strict";
}

function GetCookieValue (Name)
{
    let CookieReturnValue = undefined;
    let Cookies = document.cookie.split(";");
    for (let i = 0; i < Cookies.length; i++)
    {
        let Cookie = Cookies[i].trim();
        if (Cookie.indexOf(Name + "=") === 0)
        {
            CookieReturnValue = Cookie.substring (Name.length + 1, Cookie.length);
            break;
        }
    }
    return CookieReturnValue;
}

function RefreshCookie (Name, ExpirationDate)
{
    let Value = GetCookieValue (Name);
    if (Value !== "") SetCookie (Name, Value, ExpirationDate);
}

function DeleteCookie (Name)
{
    document.cookie = Name + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;SameSite=Strict";
}