*** Settings ***
Library     RPA.Desktop
Library     RPA.RobotLogListener


*** Tasks ***
Papierkorb ausleeren
    TRY
        Find Element    image:screenshots/Papier.png
        Wirklich ausleeren
    EXCEPT
        Log    nicht gefunden
    END


*** Keywords ***
Wirklich ausleeren
    Click    image:screenshots/Papier.png    right click
    Wait For Element    image:screenshots/leer.png
    Click    image:screenshots/leer.png    click
    Wait For Element    image:screenshots/ja.png
    Click    image:screenshots/ja.png    click
