function HideElement (ElementID)
{
    document.getElementById (ElementID).style.display = "none";
}

function ShowElementInline (ElementID)
{
    document.getElementById (ElementID).style.display = "inline";
}

function HideClass (ClassName)
{
    Elements = document.getElementsByClassName (ClassName);
    for (var i = 0; i < Elements.length; i++)
        Elements[i].style.display = "none";
}

function ShowClassInline (ClassName)
{
    Elements = document.getElementsByClassName (ClassName);
    for (var i = 0; i < Elements.length; i++)
        Elements[i].style.display = "inline";
}