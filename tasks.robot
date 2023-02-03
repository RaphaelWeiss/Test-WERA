*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Cloud.Azure
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.RobotLogListener
Library             RPA.PDF
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the Excel file
    Read the CSV File and fill the orders into the website
    Archive the List as zip


*** Keywords ***
 Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Read the CSV File and fill the orders into the website
    @{RobotOrders}=    Read table from CSV    orders.csv    header=true
    FOR    ${robotorder}    IN    @{RobotOrders}
        Close the Modal
        Choose a head    ${robotorder}[Head]
        Pick a Body    ${robotorder}[Body]
        Insert leg number    ${robotorder}[Legs]
        Type in Shipping address    ${robotorder}[Address]
        Preview the robot
        order the robot
        Loop until working
        Store the Receipt and the Robot image in a PDF File    ${robotorder}[Order number]

        order another robot
    END

Choose a head
    [Arguments]    ${headnumber}
    Select From List By Value    head    ${headnumber}

Pick a Body
    [Arguments]    ${bodytype}
    Select Radio Button    body    ${bodytype}

Insert leg number
    [Arguments]    ${numberoflegs}
    input text    css:[type=number]    ${numberoflegs}

Type in Shipping address
    [Arguments]    ${shippingaddress}
    Input Text    address    ${shippingaddress}

Preview the robot
    Click Button    preview

order the robot
    Click Button    order

Loop until working
    ${notWorking}=    does page contain element    css:.alert-danger
    WHILE    ${notWorking} == True
        Click Button    order
        ${notWorking}=    Does Page Contain Element    css:.alert-danger
    END

 order another robot
    Click Button    id:order-another

Close the Modal
    Click Button    OK

Store the Receipt and the Robot image in a PDF File
    [Arguments]    ${ORDER}
    Wait Until Element Is Visible    id:receipt
    ${Receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${Receipt_html}    ${OUTPUT_DIR}${/}receipt${ORDER}.pdf
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot${ORDER}.png
    ${Liste}=    create list    ${OUTPUT_DIR}${/}receipt${ORDER}.pdf    ${OUTPUT_DIR}${/}robot${ORDER}.png
    Create Directory    ${OUTPUT_DIR}${/}test
    Add Files To Pdf    ${Liste}    ${OUTPUT_DIR}${/}test${/}finished${ORDER}.pdf

Archive the List as zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}test    ${OUTPUT_DIR}${/}Robots.zip
