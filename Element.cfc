<cfcomponent output="false" hint="Coldfusion representation of a DOM-element, acting as a wrapper for Selenium's org.openqa.selenium.remote.RemoteWebElement-class." >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oWrappedBrowser = "" />
	<cfset oJavaWebElement = createObject("java", "java.lang.Object") />
	<cfset oSelectInterface = "" />

	<cffunction name="init" returntype="Components.Element" access="public" hint="Constructor" >
		<cfargument name="webElementReference" type="any" required="true" />
		<cfargument name="browserReference" type="Components.Browser" required="false" />
		<cfargument name="javaLoaderReference" type="any" required="false" />

		<cfset var oSelectInterface = "" />
		<cfset var stSelectInterfaceArguments = structNew() />
		<cfset stSelectInterfaceArguments.webElementReference = arguments.webElementReference />

		<cfset setJavaWebElement( WebElementReference=arguments.webElementReference ) />
		<cfif structKeyExists(arguments, "browserReference") >
			<cfset variables.oWrappedBrowser = arguments.browserReference />
		</cfif>

		<cfif structKeyExists(arguments, "javaLoaderReference") AND isObject(arguments.javaLoaderReference) >
			<cfset stSelectInterfaceArguments.javaLoaderReference = arguments.javaLoaderReference />
		</cfif>

		<cfif isSelectTag() >
			<cfset oSelectInterface = createObject("component", "Components.SelectElement").init( argumentCollection = stSelectInterfaceArguments ) />
			<cfset setSelectInterface( selectInterfaceReference=oSelectInterface ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setJavaWebElement" returntype="void" access="private" hint="" >
		<cfargument name="webElementReference" type="any" required="true" />

		<cfif isObject(arguments.webElementReference) IS false >
			<cfthrow message="Error setting Selenium's Java WebElement" detail="Argument 'WebElementReference' is not an object" />
		</cfif>

		<cfset oJavaWebElement = arguments.webElementReference />
	</cffunction>

	<cffunction name="getJavaWebElement" returntype="any" access="public" hint="Returns a reference to the Selenium Java WebElement-class that this component is wrapped around." >
		<cfreturn variables.oJavaWebElement />
	</cffunction>

	<cffunction name="getWrappedBrowser" returntype="Components.Browser" access="private" hint="Returns a reference to the Browser-instance that created this element." >
		<cfreturn variables.oWrappedBrowser />
	</cffunction>

	<cffunction name="setSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="selectInterfaceReference" type="Components.SelectElement" required="true" />

		<cfset variables.oSelectInterface = arguments.selectInterfaceReference />
	</cffunction>

	<cffunction name="getId" returntype="string" access="public" hint="Returns the ID-attribute of this element." >
		<cfreturn getJavaWebElement().getAttribute("id") />
	</cffunction>

	<cffunction name="getClassName" returntype="string" access="public" hint="Returns the CSS class name of this element." >
		<cfreturn getJavaWebElement().getAttribute("className") />
	</cffunction>

	<cffunction name="getTagName" returntype="string" access="public" hint="Returns the tag name of this element." >
		<cfreturn getJavaWebElement().getTagName() />
	</cffunction>

	<cffunction name="getName" returntype="string" access="public" hint="Returns the Name-attribute of this element." >
		<cfreturn getJavaWebElement().getAttribute("name") />
	</cffunction>

	<cffunction name="isSelectTag" returntype="boolean" access="public" hint="" >
		<cfset var sElementType = getJavaWebElement().getTagName() />

		<cfif sElementType EQ "select" >
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="getTextContent" returntype="string" access="public" hint="Returns the textContent-attribute of this element. That means all the visible, inner text without any of the nested HTML-tags wrapped around them or their attributes. Example: <span>Hello <span style='display: none;'>World</span></span> would return 'Hello world'." >
		<cfreturn trim(getJavaWebElement().getAttribute("textContent")) /> <!--- Only works in IE9+ --->
	</cffunction>

	<cffunction name="getHTMLContent" returntype="string" access="public" hint="Returns the inner, nested HTML and their contents of this element." >
		<cfargument name="encodeHTMLEntities" type="boolean" required="false" default="true" hint="Set to false to get all the special HTML entities returned in their original form, otherwise they will be encoded" />

		<cfset var sReturnData = getJavaWebElement().getAttribute("innerHTML") />

		<cfif arguments.encodeHTMLEntities >
			<cfset sReturnData = encodeForHTML(sReturnData) />
		</cfif>

		<cfreturn trim(sReturnData) />
	</cffunction>

	<cffunction name="getValue" returntype="string" access="public" hint="Returns the value-attribute of this element" >
		<cfreturn getJavaWebElement().getAttribute("value") />
	</cffunction>

	<cffunction name="getAttribute" returntype="string" access="public" hint="Returns an attribute value of this element. No matter the type of attribute it always returns a string. Boolean values are returned as 'true' or an empty string for false." >
		<cfargument name="name" type="string" required="true" />

		<cfset var sAttributeValue = "" />

		<cfif len(arguments.name) IS 0 OR arguments.name IS " " >
			<cfthrow message="Error fetching attribute value of element" detail="The attribute name you passed in argument 'Name' is blank." />
		</cfif>

		<cfset sAttributeValue = getJavaWebElement().getAttribute( arguments.name ) />

		<!--- Selenium returns null for any attributes or properties that are not defined or false boolean values which in turn makes our variable undefined --->
		<cfif isDefined("sAttributeValue") >
			<cfreturn sAttributeValue />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

	<cffunction name="isDisplayed" returntype="boolean" access="public" hint="Checks if the element is displayed. The display- and visibility-properties are used for this check." >
		<cfreturn getJavaWebElement().isDisplayed() />
	</cffunction>

	<cffunction name="isEnabled" returntype="boolean" access="public" hint="Checks if the element is enabled. The disabled-attribute is used for this check, and is typically only useful for input- and textarea-elements" >
		<cfreturn getJavaWebElement().isEnabled() />
	</cffunction>

	<cffunction name="isSelected" returntype="boolean" access="public" hint="Checks if the element is selected or not. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag. It will just return false." >
		<cfreturn getJavaWebElement().isSelected() />
	</cffunction>

	<cffunction name="selectIfNotSelected" returntype="void" access="public" hint="Selects this element if it's de-selected, otherwise won't do anything. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag." >
		<cfif isSelected() IS false >
			<cfset click() />
		</cfif>
	</cffunction>

	<cffunction name="deselectIfSelected" returntype="void" access="public" hint="De-selects this element if it's already selected, otherwise won't do anything. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag." >
		<cfif isSelected() >
			<cfset click() />
		</cfif>
	</cffunction>

	<cffunction name="write" returntype="void" access="public" hint="Simulate typing into this element. For some elements this will manipulate the value-attribute" >
		<cfargument name="text" type="array" required="true" hint="An array with each entry being a string that will be typed into the element" />
		<cfargument name="addToExistingText" type="boolean" required="false" default="false" hint="By default whatever text is already in the element will be cleared. Pass this as true to add to the existing text instead." />

		<cfset var sCurrentTextIndex = "" />
		<cfset var nArrayIterator = 1 />

		<cfloop array=#arguments.text# index="sCurrentTextIndex" >
			<cfset arguments.text[nArrayIterator] = toString(sCurrentTextIndex) />
			<cfset nArrayIterator = (nArrayIterator + 1) />
		</cfloop>

		<cftry>
			<cfif arguments.addToExistingText IS false >
				<cfset clearText() />
			</cfif>
			<cfset getJavaWebElement().sendKeys(arguments.text) />

			<cfcatch type="org.openqa.selenium.ElementNotVisibleException" >
				<cfthrow message="Error when writing in element" detail="Can't write in the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>

			<cfcatch type="org.openqa.selenium.InvalidElementStateException" >
				<cfthrow message="Error when writing in element" detail="Can't write in the element, likely because it's disabled, obscured or not a type of element you can type text in. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="click" returntype="void" access="public" hint="Click this element. There are some preconditions for the element to be clicked: it must be visible and it must have a height and width greater than 0." >
		<cfset sleep(200) />
		<cftry>
			<cfset getJavaWebElement().click() />

			<cfcatch type="org.openqa.selenium.ElementNotVisibleException" >
				<cfthrow message="Error when clicking on element" detail="Can't click on the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>

			<cfcatch type="org.openqa.selenium.WebDriverException" >
				<cfif findNoCase("is not clickable at point (", cfcatch.message) GT 0 >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element. Likely because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				<cfelse>
					<cfthrow object="#cfcatch#" />
				</cfif>
			</cfcatch>
			
		</cftry>
	</cffunction>

	<cffunction name="clearText" returntype="void" access="public" hint="Clear this element's value, if this element is a text element (input and textarea)" >
		<cfset getJavaWebElement().clear() />
	</cffunction>

	<cffunction name="submitForm" returntype="void" access="public" hint="If this element is a form, or an element within a form, then this will be submitted" >
		<cftry>
			<cfset getJavaWebElement().submit() />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Form submission failed" detail="The element you called submitForm() on is not part of a form. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="select" returntype="Components.SelectElement" access="public" hint="Returns a reference to the interface used for interacting with the special functions of a select-tag. If this element is not a select-tag then an error will be thrown" >

		<cfif isSelectTag() IS false >
			<cfthrow message="Error getting select-tag interface" detail="You can't use select-methods on this element because it's not a select-tag. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
		</cfif>

		<cfreturn oSelectInterface />
	</cffunction>

	<cffunction name="getElement" returntype="any" access="public" hint="Returns one or more elements that matches your search criteria, that are nested within this element. This method will throw an error if NO elements are found when searching for single element." >
		<cfargument name="searchFor" type="string" required="true" hint="The search string to locate the element by. Can be an id, tag-name, class name, xpath, css selector etc" />
		<cfargument name="locateUsing" type="array" required="false" default="#arrayNew(1)#" hint="The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName,javascript" />
		<cfargument name="locateHiddenElements" type="boolean" required="false" default="false" hint="Use this to determine whether to return only elements that are considered visible or not." />
		<cfargument name="multiple" type="boolean" required="false" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var ReturnData = "" />
		<cfset var stGetElementsArguments = {
			searchFor=arguments.searchFor,
			locateUsing=arguments.locateUsing,
			locateHiddenElements=arguments.locateHiddenElements,
			searchContext=getJavaWebElement()
		} />

		<cfif arguments.multiple > 
			<cfset ReturnData = oWrappedBrowser.getElements(argumentCollection = stGetElementsArguments) />
		<cfelse>
			<cfset ReturnData = oWrappedBrowser.getElement(argumentCollection = stGetElementsArguments) />
		</cfif>

		<cfreturn ReturnData />
	</cffunction>

	<cffunction name="getParentElement" returntype="Components.Element" access="public" hint="" >

		<cfreturn getWrappedBrowser().getElement(
			searchFor="return arguments[0].parentElement",
			locateUsing=["javascript"],
			javascriptArguments=[getJavaWebElement()]
		) />

	</cffunction>

	<cffunction name="getPreviousSiblingElement" returntype="Components.Element" access="public" hint="" >

		<cfreturn getWrappedBrowser().getElement(
			searchFor="return arguments[0].previousElementSibling",
			locateUsing=["javascript"],
			javascriptArguments=[getJavaWebElement()]
		) />

	</cffunction>

	<cffunction name="getNextSiblingElement" returntype="Components.Element" access="public" hint="" >

		<cfreturn getWrappedBrowser().getElement(
			searchFor="return arguments[0].nextElementSibling",
			locateUsing=["javascript"],
			javascriptArguments=[getJavaWebElement()]
		) />

	</cffunction>

	<cffunction name="getChildElements" returntype="array" access="public" hint="" >

		<cfreturn getWrappedBrowser().getElements(
			searchFor="return arguments[0].children",
			locateUsing=["javascript"],
			javascriptArguments=[getJavaWebElement()]
		) />

	</cffunction>

</cfcomponent>