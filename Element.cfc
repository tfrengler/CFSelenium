<cfcomponent output="false" modifier="final" hint="Coldfusion representation of a DOM-element, acting as a wrapper for Selenium's org.openqa.selenium.remote.RemoteWebElement-class." >

	<cfset variables.oWrappedBrowser = "" /> <!--- CF-component reference --->
	<cfset variables.oJavaWebElement = "" /> <!--- Java-object reference --->
	<cfset variables.oSelectInterface = "" /> <!--- CF-component reference --->
	<cfset variables.oLocator = "" /> <!--- CF-component reference --->
	<cfset variables.eventManager = "" />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="Element" access="public" hint="Constructor" >
		<cfargument name="webElementReference" type="any" required="true" hint="A reference to the Java remote.RemoteWebElement-class." />
		<cfargument name="locatorReference" type="Locator" required="false" hint="A reference to the Locator-instance that was used to find this element." />
		<cfargument name="browserReference" type="Browser" required="true" hint="A reference to the Browser-instance that was used to fetch this element." />
		<cfargument name="eventManagerReference" type="EventManager" required="false" />

		<cfset var stSelectElementArguments = {
			elementReference=this
		} />

		<cfif isObject(arguments.webElementReference) IS false >
			<cfthrow message="Error setting Java WebElement" detail="Argument 'webElementReference' is not an object" />
		</cfif>

		<cfif structKeyExists(arguments, "eventManagerReference") >
			<cfset variables.eventManager = arguments.eventManagerReference />
			<cfset stSelectElementArguments.eventManagerReference = arguments.eventManagerReference />
		</cfif>

		<cfif structKeyExists(arguments, "locatorReference") >
			<cfset variables.oLocator = arguments.locatorReference />
		</cfif>

		<cfset variables.oJavaWebElement = arguments.webElementReference />
		<cfset variables.oWrappedBrowser = arguments.browserReference />

		<cfif isSelectTag() >
			<cfset variables.oSelectInterface = new SelectElement(argumentCollection = stSelectElementArguments) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- PUBLIC SETTERS/GETTERS --->

	<cffunction name="getWrappedBrowser" returntype="Browser" access="public" hint="Returns a reference to the Browser-component that is wrapped around this Element-instance." >
		<cfreturn variables.oWrappedBrowser />
	</cffunction>

	<cffunction name="getLocator" returntype="Locator" access="public" hint="Returns a reference to the Locator-instance that was used to fetch this element." >
		<cfreturn variables.oLocator />
	</cffunction>

	<cffunction name="getJavaWebElement" returntype="any" access="public" hint="Returns a reference to the Java remote.RemoteWebElement-class that this component is wrapped around." >
		<cfreturn variables.oJavaWebElement />
	</cffunction>

	<cffunction name="select" returntype="SelectElement" access="public" hint="Returns a reference to the interface used for interacting with the special functions of a select-tag. If this element is not a select-tag then an error will be thrown" >
		<cfif isSelectTag() IS false >
			<cfthrow message="Error getting select-tag interface" detail="You can't use select-methods on this element because it's not a select-tag. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
		</cfif>

		<cfreturn variables.oSelectInterface />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="getId" returntype="string" access="public" hint="Returns the ID-attribute of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.getAttribute("id") />
	</cffunction>

	<cffunction name="getClassName" returntype="string" access="public" hint="Returns the CSS class name of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.getAttribute("className") />
	</cffunction>

	<cffunction name="getTagName" returntype="string" access="public" hint="Returns the tag name of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.getTagName() />
	</cffunction>

	<cffunction name="getName" returntype="string" access="public" hint="Returns the Name-attribute of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.getAttribute("name") />
	</cffunction>

	<cffunction name="isSelectTag" returntype="boolean" access="public" hint="Use to determine whether this is a select-tag or not." >
		<cfreturn variables.oJavaWebElement.getTagName() EQ "select" >
	</cffunction>

	<!--- Important to note that some elements don't have innerText, like <textarea> --->
	<cffunction name="getTextContent" returntype="string" access="public" hint="Returns the visible text content. Textcontent means all the visible, inner text without any of the nested HTML-tags wrapped around them or their attributes. Example: calling this on the outer span of this: <span>Hello <span style='display: none;'>World</span></span> - would return 'Hello world'." >
		<cfargument name="raw" type="boolean" required="false" default="false" hint="When passed, this returns the full text content, including all tabs, line feeds, line breaks, double-spaces etc" />
		<cfargument name="trimExtra" type="boolean" required="false" default="false" hint="This will remove things that are not whitespace, so stuff like &nbsp; etc" />

		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfif arguments.raw OR variables.oJavaWebElement.getTagName() EQ "textarea" >
			<cfreturn trim(variables.oJavaWebElement.getAttribute("textContent")) /> <!--- Only works in IE9+ --->
		</cfif>

		<cfif arguments.trimExtra >
			<cfreturn variables.oWrappedBrowser.runJavascript(script="return arguments[0].innerText.trim()", parameters=[getJavaWebElement()]) />
		</cfif>

		<cfreturn trim(variables.oJavaWebElement.getAttribute("innerText")) <!--- IE10+ ---> />
	</cffunction>

	<cffunction name="getHTMLContent" returntype="string" access="public" hint="Returns the inner, nested HTML and their contents of this element." >
		<cfargument name="encodeHTMLEntities" type="boolean" required="false" default="true" hint="Set to false to get all the special HTML entities returned in their original form, otherwise they will be encoded" />

		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var sReturnData = variables.oJavaWebElement.getAttribute("innerHTML") />

		<cfif arguments.encodeHTMLEntities >
			<cfreturn encodeForHTML(trim(sReturnData)) />
		</cfif>

		<cfreturn trim(sReturnData) />
	</cffunction>

	<cffunction name="getValue" returntype="string" access="public" hint="Returns the value-attribute of this element" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfreturn variables.oJavaWebElement.getAttribute("value") />
	</cffunction>

	<cffunction name="getAttribute" returntype="string" access="public" hint="Returns an attribute value of this element. No matter the type of attribute it always returns a string. Boolean values are returned as 'true' or an empty string for false." >
		<cfargument name="name" type="string" required="true" />

		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var sAttributeValue = "" />

		<cfif len(arguments.name) IS 0 OR arguments.name IS " " >
			<cfthrow message="Error fetching attribute value of element" detail="The attribute name you passed in argument 'name' is blank." />
		</cfif>

		<cfset sAttributeValue = variables.oJavaWebElement.getAttribute( arguments.name ) />

		<!--- Selenium returns null for any attributes or properties that are not defined and for false boolean values which in turn makes our variable undefined --->
		<cfif isDefined("sAttributeValue") AND len(sAttributeValue) GT 0 >
			<cfreturn sAttributeValue />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction name="isDisplayed" returntype="boolean" access="public" hint="Checks if the element is displayed. The display- and visibility-properties are used for this check." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.isDisplayed() />
	</cffunction>

	<cffunction name="isEnabled" returntype="boolean" access="public" hint="Checks if the element is enabled. The disabled-attribute is used for this check, and is typically only useful for input- and textarea-elements" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.isEnabled() />
	</cffunction>

	<cffunction name="isSelected" returntype="boolean" access="public" hint="Checks if the element is selected or not. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag. It will just return false." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>
		<cfreturn variables.oJavaWebElement.isSelected() />
	</cffunction>

	<cffunction name="selectIfNotSelected" returntype="Element" access="public" hint="Selects this element if it's de-selected, otherwise won't do anything. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfif isSelected() IS false >
			<cfset click() />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="deselectIfSelected" returntype="Element" access="public" hint="De-selects this element if it's already selected, otherwise won't do anything. This only applies to input elements such as checkboxes, radio buttons and options-elements nested inside select-tags. Will not throw errors if you use this on a non-selectable tag." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfif isSelected() >
			<cfset click() />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="write" returntype="Element" access="public" hint="Simulate typing into this element. For some elements this will manipulate the value-attribute" >
		<cfargument name="text" type="array" required="true" hint="An array with each entry being a string that will be typed into the element" />
		<cfargument name="addToExistingText" type="boolean" required="false" default="false" hint="By default whatever text is already in the element will be cleared. Pass this as true to add to the existing text instead." />
		<cfargument name="convertToStrings" type="boolean" required="false" default="true" hint="Use this to turn off the forced conversion all the array values from parameter 'text' to string. Selenium will throw an exception if a value in the array is NOT a string." />

		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfif arguments.convertToStrings >
			<cfset arguments.text = javaCast("java.lang.String[]", arguments.text) />
		</cfif>

		<cftry>
			<cfif arguments.addToExistingText IS false >
				<cfset clearText() />
			</cfif>

			<cfset variables.oJavaWebElement.sendKeys(arguments.text) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" >
					<cfthrow message="Error when writing in element" detail="Can't write in the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfif cfcatch.type IS "org.openqa.selenium.InvalidElementStateException" >
					<cfthrow message="Error when writing in element" detail="Can't write in the element, likely because it's disabled, obscured or not a type of element you can type text in. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfif cfcatch.type IS "org.openqa.selenium.WebDriverException" AND findNoCase("keys should be a string", cfcatch.message) GT 0 >
					<cfthrow message="Error when writing in element" detail="Can't write in the element. One of the array keys from argument 'text' is NOT a string. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<cffunction name="click" returntype="Element" access="public" hint="Click this element. There are some preconditions for the element to be clicked: it must be visible and it must have a height and width greater than 0." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cftry>
			<cfset variables.oJavaWebElement.click() />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementClickInterceptedException" OR cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" OR (cfcatch.type IS "org.openqa.selenium.WebDriverException" AND findNoCase("is not clickable at point (", cfcatch.message) GT 0) >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element. Likely because it's not visible, partially hidden/obscured or not ready yet due to dynamic loading (dialogs) or animations that aren't finished. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<cffunction name="clickUsingEnter" returntype="Element" access="public" hint="An alternative to click(), which uses the keyboard to press 'Enter' on the element instead of clicking with the mouse." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cftry>
			<cfset variables.oJavaWebElement.sendKeys( [variables.oWrappedBrowser.getJavaloader().create("org.openqa.selenium.Keys").ENTER] ) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" OR (cfcatch.type IS "org.openqa.selenium.WebDriverException" AND findNoCase("is not clickable at point (", cfcatch.message) GT 0) >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element. Likely because it's not visible, partially hidden/obscured or not ready yet due to dynamic loading (dialogs) or animations that aren't finished. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<cffunction name="clickUsingJS" returntype="Element" access="public" hint="An alternative to click(), which uses Javascript to invoke the click()-method on the element instead of clicking with the mouse." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cftry>
			<cfset variables.oWrappedBrowser.runJavascript(script="arguments[0].click()", parameters=[variables.oJavaWebElement]) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.ElementNotVisibleException" OR (cfcatch.type IS "org.openqa.selenium.WebDriverException" AND findNoCase("is not clickable at point (", cfcatch.message) GT 0) >
					<cfthrow message="Error when clicking on element" detail="Can't click on the element. Likely because it's not visible, partially hidden/obscured or not ready yet due to dynamic loading (dialogs) or animations that aren't finished. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<cffunction name="clearText" returntype="Element" access="public" hint="Clear this element's value, if this element is a text element (input and textarea)" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset variables.oJavaWebElement.clear() />
		<cfreturn this />
	</cffunction>

	<cffunction name="submitForm" returntype="void" access="public" hint="If this element is a form, or an element within a form, then the form will be submitted. NOTE: This circumvents any eventhandlers that are attached to the submit-button!" >
		<cftry>
			<cfset variables.oJavaWebElement.submit() />

			<cfcatch >
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Form submission failed" detail="The element you called submitForm() on is not part of a form. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getElement" returntype="any" access="public" hint="Returns either the FIRST element or an array of ALL elements that matches your locator, which are nested within this element. This method will throw an error if NO elements are found when searching for single element." >
		<cfargument name="locator" type="Locator" required="true" hint="An instance of the locator mechanism you want to use to search for the elements" />
		<cfargument name="locateHiddenElements" type="boolean" required="false" default="#variables.oWrappedBrowser.getFetchHiddenElements()#" hint="Use this to determine whether to return only elements that are considered visible or not." />
		<cfargument name="multiple" type="boolean" required="false" default="false" hint="Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found." />

		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var stGetElementsArguments = arguments />
		<cfset stGetElementsArguments.searchContext = getJavaWebElement() />

		<cfreturn variables.oWrappedBrowser.getElement(argumentCollection = stGetElementsArguments) />
	</cffunction>

	<cffunction name="getParentElement" returntype="Element" access="public" hint="Returns the parent element of this element" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].parentElement",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cfreturn variables.oWrappedBrowser.getElement(locator=oLocator) />

	</cffunction>

	<cffunction name="getPreviousSiblingElement" returntype="Element" access="public" hint="Returns the previous (upper) sibling/neighbour-element of this element" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].previousElementSibling",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn variables.oWrappedBrowser.getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting previous sibling element" detail="This element does not have a previous sibling. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getNextSiblingElement" returntype="Element" access="public" hint="Returns the next (lower) sibling/neighbour-element of this element" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].nextElementSibling",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn variables.oWrappedBrowser.getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting next sibling element" detail="This element does not have a next sibling. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getChildElements" returntype="array" access="public" hint="Returns an array of all elements that are direct children of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].children",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cfset var aReturnData = variables.oWrappedBrowser.getElement(locator=oLocator, multiple=true) />

		<cfif arrayLen(aReturnData) IS 0 >
			<cfthrow message="Error getting child elements" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
		</cfif>

		<cfreturn aReturnData />
	</cffunction>

	<cffunction name="getFirstChildElement" returntype="Element" access="public" hint="Returns the FIRST element that is a direct child of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].firstElementChild",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn variables.oWrappedBrowser.getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting first child element" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getLastChildElement" returntype="Element" access="public" hint="Returns the LAST element that is a direct child of this element." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oLocator = variables.oWrappedBrowser.createLocator(
			searchFor = "return arguments[0].lastElementChild",
			locateUsing = "javascript",
			javascriptArguments = [getJavaWebElement()]
		) />

		<cftry>
			<cfreturn variables.oWrappedBrowser.getElement(locator=oLocator) />

			<cfcatch>
				<cfif find("Unable to find HTML-element", cfcatch.detail) GT 0 >
					<cfthrow message="Error getting last child element" detail="This element does not have any child elements. Tag: #getTagName()# | id: #getID()# | Name: #getName()# | Class: #getClassName()# | Locator string: #variables.oLocator.getLocatorString()# | Locator mechanism: #variables.oLocator.getLocatorMechanism()#" />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="scrollToAndFocusOn" returntype="Element" access="public" hint="Moves the mouse to this element which causes it to be scrolled into view" >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var oActions = "" />

		<cfif isObject(variables.oWrappedBrowser.getJavaloader()) >
			<cfset oActions = variables.oWrappedBrowser.getJavaloader().create("org.openqa.selenium.interactions.Actions").init(
				variables.oWrappedBrowser.getJavaWebDriver()
			) />
		<cfelse>
			<cfset oActions = createObject("java", "org.openqa.selenium.interactions.Actions").init(
				variables.oWrappedBrowser.getJavaWebDriver()
			) />
		</cfif>

		<cfset oActions.moveToElement(variables.getJavaWebElement()).perform() />

		<cfreturn this />
	</cffunction>

	<cffunction name="scrollIntoView" returntype="Element" access="public" hint="Scrolls this element into view but does not focus on it. Similar in many ways to scrollToAndFocusOn(), but is a more unstable solution that uses the Y-position of the viewport and the element to determine if the element is out of view, and then executes JS to scroll to the element. Consider it an (expensive) alternative to scrollToAndFocusOn, which is the recommended method." >
		<cfif isObject(variables.eventManager) >
			<cfset variables.eventManager.log("Browser", getFunctionCalledName(), arguments) />
		</cfif>

		<cfset var nWindowHeight = variables.oWrappedBrowser.getJavaWebDriver().manage().window().getSize().height />

		<cfif variables.oJavaWebElement.location.y GT nWindowHeight >

			<cfset variables.oWrappedBrowser.runJavascript(
				script="window.scrollTo(0, #variables.oJavaWebElement.location.y + variables.oJavaWebElement.size.height#)"
			) />

		</cfif>

		<cfreturn this />
	</cffunction>

</cfcomponent>