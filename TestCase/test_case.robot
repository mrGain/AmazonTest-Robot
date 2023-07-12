*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    String

*** Variables ***
${Browser}    Chrome
${url}    https://www.amazon.com
${Expected URL}    https://www.amazon.com/s?i=specialty-aps&bbn=16225009011&rh=n%3A%2116225009011%2Cn%3A2811119011&ref=nav_em__nav_desktop_sa_intl_cell_phones_and_accessories_0_2_5_5

*** Test Cases ***
Testing Product List
    Open Browser    ${url}    ${Browser}    incognito
    Maximize Browser Window
    Sleep    10s
    Set Selenium Speed    0.5s
    Click Link    xpath://a[@id="nav-hamburger-menu"]
    Click Link    xpath://a[@class="hmenu-item" and @data-menu-id="5"]
    Click Link    xpath://a[@class="hmenu-item" and contains(text(),'Cell Phones & Accessories')]
    Sleep    2s
    Verify Page
    Sleep    3s
    Click Element    xpath://li[@id="p_72/1248879011"]
    ${product_data_first}    Get Amazone Product Data
    ${product_data_first}     Delete items with 'None' values    ${product_data_first}
    ${length_first}    Get Dictionary Length    ${product_data_first}
    Log To Console    ${length_first}
    ${smallest_value}    Find Smallest Value and Delete All Values    ${product_data_first}
    #Log To Console    ${smallest_value}
    Click Element    xpath://li[@id="p_36/1253507011"]
    ${product_data_second}    Get Amazone Product Data
    ${final_dictionary}    Insert Key and Value to Dictionary    ${product_data_second}    ${smallest_value}
    # Log To Console    ${final_dictionary}
    ${length}    Get Dictionary Length    ${final_dictionary}
    Log To Console    ${length}
    Close Browser

*** Keywords ***
Verify Page
    Location Should Be    ${Expected URL}  
Get Amazone Product Data
    Set Selenium Speed    0.5s
    @{product_name_elements}    Get WebElements    xpath://span[@class="a-size-base-plus a-color-base a-text-normal"]
    # @{price_elements}    Get WebElements    xpath://span[@class="a-offscreen"]
    @{price_elements}    Get WebElements    xpath://span[@class="a-price"]
    ${product_names}    Create List
    ${prices}    Create List
    FOR   ${element}    IN    @{product_name_elements}
        ${product_name}    Get Text    ${element}
        Append To List    ${product_names}    ${product_name}
    END
    FOR    ${element}    IN    @{price_elements}
        ${price}    Get Text    ${element}
        ${price}    Replace String    ${price}    \n    .
        Append To List    ${prices}    ${price}
    END
    # Log To Console    ${prices}
    ${product_data}    Create Dictionary
    FOR    ${index}    IN RANGE    ${product_names.__len__()}
        ${product_name}    Set Variable    ${product_names[${index}]}
        ${price}    Run Keyword If    ${index} < ${prices.__len__()}    Get From List    ${prices}    ${index}
        Set To Dictionary    ${product_data}    ${product_name}=${price}
    END
    # Log To Console  ${product_data}
    Return From Keyword    ${product_data}
    
Find Smallest Value and Delete All Values
    [Arguments]    ${dictionary}
    ${smallest_key}    ${smallest_value}    Evaluate    min(${dictionary}.items(), key=lambda x: float(x[1].replace('$', '').replace(',', '')))
    Remove All Values    ${dictionary}
    [Return]    ${smallest_key}    ${smallest_value}

Remove All Values
    [Arguments]    ${dictionary}
    ${keys}    Get Dictionary Keys    ${dictionary}
    FOR    ${key}    IN    @{keys}
        Remove From Dictionary    ${dictionary}    ${key}
    END

Insert Key and Value to Dictionary
    [Arguments]    ${dictionary}    ${smallest_value}
    Set To Dictionary    ${dictionary}    ${smallest_value[0]}    ${smallest_value[1]}
    [Return]    ${dictionary}

Get Dictionary Length
    [Arguments]    ${dictionary}
    ${length}    Evaluate    len(${dictionary})
    [Return]    ${length}

 Delete items with 'None' values
    [Arguments]    ${product_data}
    ${keys_to_delete}    Create List
    FOR    ${key}    IN    @{product_data.keys()}
        ${value}    Get From Dictionary    ${product_data}    ${key}
        Run Keyword If    '${value}' == 'None'    Append To List    ${keys_to_delete}    ${key}
    END
    FOR    ${key}    IN    @{keys_to_delete}
        Remove From Dictionary    ${product_data}    ${key}
    END

    [Return]    ${product_data}