permissionset 70100 GP_GMPI
{
    Assignable = true;
    Permissions = tabledata "WHT Posting Setup"=R,
        tabledata "Sales Line"=RIM,
        tabledata "GMPI AR Code"=RIMD,
        tabledata "GMPI Credit Score"=RIMD,
        tabledata "GMPI Principal"=RIMD,
        table "GMPI AR Code"=X,
        table "GMPI Credit Score"=X,
        table "GMPI Principal"=X,
        page "GMPI AR Code List"=X,
        page "GMPI Credit Score List"=X,
        page "GMPI Principal List"=X,
        tabledata "GMPI Brand"=RIMD,
        table "GMPI Brand"=X,
        page "GMPI Brand List"=X;
}
