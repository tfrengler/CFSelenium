<cfcomponent output="false" hint="Coldfusion representation of a DOM-element, acting as a wrapper for Selenium's org.openqa.selenium.remote.RemoteWebElement-class." >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oWrappedBrowser = "" />
	<cfset oJavaWebElement = createObject("java", "java.lang.Object") />
	<cfset oSelectInterface = "" />
	<cfset oLocator = structNew() />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="Components.Element" access="public" hint="Constructor" >
		<cfargument name="webElementReference" type="any" required="true" hint="A reference to the Java remote.RemoteWebElement-class." />
		<cfargument name="locatorReference" type="Components.Locator" required="false" hint="A reference to the Locator-instance that was used to find this element." />
		<cfargument name="browserReference" type="Components.Browser" required="true" hint="A reference to the Browser-instance that was used to fetch this element." />
		<cfargument name="javaLoaderReference" type="any" required="false" hint="A reference to Mark Mandel's Javaloader-component." />

		<cfset var oSelectInterface = "" />
		<cfset var stSelectInterfaceArguments = structNew() />
		
		<cfset stSelectInterfaceArguments.webElementReference = arguments.webElementReference />
		<cfset stSelectInterfaceArguments.browserReference = arguments.browserReference />
		<cfset setJavaWebElement(data=arguments.webElementReference) />

		<cfif structKeyExists(arguments, "locatorReference") >
			<cfset setLocator(data=arguments.locatorReference) />
		</cfif>
		<cfset setWrappedBrowser(data=arguments.browserReference) />

		<cfif structKeyExists(arguments, "javaLoaderReference") AND isObject(arguments.javaLoaderReference) >
			<cfset stSelectInterfaceArguments.javaLoaderReference = arguments.javaLoaderReference />
		</cfif>

		<cfif isSelectTag() >
			<cfset oSelectInterface = createObject("component", "Components.SelectElement").init(
				argumentCollection = stSelectInterfaceArguments
			) />
			<cfset setSelectInterface(data=oSelectInterface) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- PRIVATE METHODS --->

	<cffunction name="setJavaWebElement" returntype="void" access="private" hint="" >
		<cfargument name="data" type="any" required="true" />

		<cfif isObject(arguments.data) IS false >
			<cfthrow message="Error setting Java WebElement" detail="Argument 'data' is not an object" />
		</cfif>

		<cfset variables.oJavaWebElement = arguments.data />
	</cffunction>

	<cffunction name="setLocator" returntype="void" access="private" hint="" >
		<cfargument name="data" type="Components.Locator" required="true" />

		<cfset variables.oLocator = arguments.data />
	</cffunction>

	<cffunction name="setWrappedBrowser" returntype="void" access="private" hint="" >
		<cfargument name="data" type="Components.Browser" required="true" />

		<cfset variables.oWrappedBrowser = arguments.data />
	</cffunction>

	<cffunction name="getWrappedBrowser" returntype="Components.Browser" access="private" hint="Returns a reference to the Browser-instance that created this element." >
		<cfreturn variables.oWrappedBrowser />
	</cffunction>

	<cffunction name="setSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="data" type="Components.SelectElement" required="true" />

		<cfset variables.oSelectInterface = arguments.data />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="getLocator" returntype="Components.Locator" access="public" hint="Returns a reference to the Locator-instance that was used to fetch this element." >
		<cfreturn variables.oLocator />
	</cffunction>

	<cffunction name="getJavaWebElement" returntype="any" access="public" hint="Returns a reference to the Java remote.RemoteWebElement-class that this component is wrapped around." >
		<cfreturn variables.oJavaWebElement />
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

	<cffunction name="isSelectTag" returntype="boolean" access="public" hint="Use to determine whether this is a select-tag or not." >
		<cfset var sElementType = getJavaWebElement().getTagName() />

		<cfif sElementType EQ "select" >
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="getTextContent" returntype="string" access="public" hint="Returns the textContent-attribute of this element. Note that this is not supported IE8 and below! Textconent means all the visible, inner text without any of the nested HTML-tags wrapped around them or their attributes. Example: calling this on the outer span of this: <span>Hello <span style='display: none;'>World</span></span> - would return 'Hello world'." >
		<cfset var sRawTextContent = getJavaWebElement().getAttribute("textContent") /> <!--- Only works in IE9+ --->
		<cfset var sCleanedReturnData = "" />
		<!--- The inner contents of our elements are often littered with extra spaces, carriage returns, tabs and newlines --->
		<cfset sCleanedReturnData = reReplace(sRawTextContent, "[\t\n\r]", "", "ALL") />
		<cfset sCleanedReturnData = replace(sCleanedReturnData, chr(160), "", "ALL") /> <!--- &nbsp; --->

		<cfreturn trim(sCleanedReturnData) />
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
			<cfthrow message="Error fetching attribute value of element" detail="The attribute name you passed in argument 'name' is blank." />
		</cfif>

		<cfset sAttributeValue = getJavaWebElement().getAttribute( arguments.name ) />

		<!--- Selenium returns null for any attributes or properties that are not defined or false boolean values which in turn makes our variable undefined --->
		<cfif isDefined("sAttributeValue") AND len(sAttributeValue) GT 0 >
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

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" >
					<cfthrow message="Error when writing in element" detail="Can't write in the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				</cfif>

				<cfif cfcatch.type IS "org.openqa.selenium.InvalidElementStateException" >
					<cfthrow message="Error when writing in element" detail="Can't write in the element, likely because it's disabled, obscured or not a type of element you can type text in. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="click" returntype="void" access="public" hint="Click this element. There are some preconditions for the element to be clicked: it must be visible and it must have a height and width greater than 0." >
		<cfset sleep(50) />
		<cftry>
			<cfset getJavaWebElement().click() />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				</cfif>

				<cfif cfcatch.type IS "org.openqa.selenium.WebDriverException" AND findNoCase("is not clickable at point (", cfcatch.message) GT 0 >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element. Likely because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="clearText" returntype="void" access="public" hint="Clear this element's value, if this element is a text element (input and textarea)" >
		<cfset getJavaWebElement().clear() />
	</cffunction>

	<cffunction name="submitForm" returntype="void" access="public" hint="If this element is a form, or an element within a form, then the form will be submitted. NOTE: This circumvents any eventhandlers that are attached to the submit-button!" >
		<cftry>
			<cfset getJavaWebElement().submit() />

			<cfcatch >
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Form submission failed" detail="The element you called submitForm() on is not part of a form. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="select" returntype="Components.SelectElement" access="public" hint="Returns a reference to the interface used for interacting with the special functions of a select-tag. If this element is not a select-tag then an error will be thrown" >

		<cfif isSelectTag() IS false >
			<cfthrow message="Error getting select-tag interface" detail="You can't use select-methods on this element because it's not a select-tag. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
		</cfif>

		<cfreturn variables.oSelectInterface />
	</cffunction>

	<cffunction name="getElement" returntype="any" access="public" hint="Returns either the FIRST element or an array of ALL elements that matches your locator, which are nested within this element. This method will throw an error if NO elements are found when searching for single element." >
		<cfargument name="locator" type="Components.Locator" required="true" hint="An instance of the locator mechanism you want to use to search for the elements" />
		<cfargument name="locateHiddenElements" type="boolean" required="false" default="#getWrappedBrowser().getFetchHiddenElements()#" hint="Use this to determine whether to return only elements that are considered visible or not." />
		<cfargument name="multiple" type="boolean" required="false" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfset var stGetElementsArguments = arguments />
		<cfset stGetElementsArguments.searchContext = getJavaWebElement() />

		<cfreturn getWrappedBrowser().getElement(argumentCollection = stGetElementsArguments) />
	</cffunction>

	<cffunction name="getParentElement" returntype="Components.Element" access="public" hint="" >

		<cfset var oLocator = "" />
		<cfset var stLocatorArguments = structNew() />

		<cfset stLocatorArguments.searchFor = "return arguments[0].parentElement" />
		<cfset stLocatorArguments.locateUsing = "javascript" />
		<cfset stLocatorArguments.javascriptArguments = [getJavaWebElement()] />

		<cfset oLocator = getWrappedBrowser().createLocator(
			argumentCollection = stLocatorArguments
		) />

		<cfreturn getWrappedBrowser().getElement(locator=oLocator) />

	</cffunction>

	<cffunction name="getPreviousSiblingElement" returntype="Components.Element" access="public" hint="" >

		<cfset var oLocator = "" />

		<cfset oLocator = getWrappedBrowser().createLocator(
			searchFor = "return arguments[0].previousElementSibling",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn getWrappedBrowser().getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting previous sibling element" detail="This element does not have a previous sibling. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getNextSiblingElement" returntype="Components.Element" access="public" hint="" >

		<cfset var oLocator = "" />

		<cfset oLocator = getWrappedBrowser().createLocator(
			searchFor = "return arguments[0].nextElementSibling",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn getWrappedBrowser().getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting next sibling element" detail="This element does not have a next sibling. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getChildElements" returntype="array" access="public" hint="" >

		<cfset var oLocator = "" />
		<cfset var aReturnData = arrayNew(1) />

		<cfset oLocator = getWrappedBrowser().createLocator(
			searchFor = "return arguments[0].children",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cfset aReturnData = getWrappedBrowser().getElement(locator=oLocator, multiple=true) />

		<cfif arrayLen(aReturnData) IS 0 >
			<cfthrow message="Error getting child elements" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
		</cfif>

		<cfreturn aReturnData />
	</cffunction>

	<cffunction name="getFirstChildElement" returntype="Components.Element" access="public" hint="" >

		<cfset var oLocator = "" />

		<cfset oLocator = getWrappedBrowser().createLocator(
			searchFor = "return arguments[0].firstElementChild",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn getWrappedBrowser().getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting first child element" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getLastChildElement" returntype="Components.Element" access="public" hint="" >

		<cfset var oLocator = "" />

		<cfset oLocator = getWrappedBrowser().createLocator(
			searchFor = "return arguments[0].lastElementChild",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn getWrappedBrowser().getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting last child element" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>