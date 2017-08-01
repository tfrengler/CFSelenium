<cfcomponent output="false" hint="Coldfusion representation of a DOM-element, primarily acting as a wrapper for Selenium's org.openqa.selenium.remote.RemoteWebElement class" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaWebElement = createObject("java", "java.lang.Object") />
	<cfset oSelectInterface = "" />

	<cffunction name="init" returntype="Element" access="public" hint="Constructor" >
		<cfargument name="WebElementReference" type="any" required="true" />

		<cfset var oSelectInterface = "" />

		<cfset setJavaWebElement( WebElementReference=arguments.WebElementReference ) />

		<cfif isSelectTag() >
			<cfset oSelectInterface = createObject("component", "SelectElement").init( WebElementReference=arguments.WebElementReference ) />
			<cfset setSelectInterface( SelectInterfaceReference=oSelectInterface ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setJavaWebElement" returntype="void" access="private" hint="" >
		<cfargument name="WebElementReference" type="any" required="true" />

		<cfif isObject(arguments.WebElementReference) IS false >
			<cfthrow message="Argument 'WebElementReference' is not an object" />
		</cfif>
		<cfif isInstanceOf(arguments.WebElementReference, "org.openqa.selenium.remote.RemoteWebElement") IS false >
			<cfthrow message="Argument 'WebElementReference' is not an instance of 'org.openqa.selenium.remote.RemoteWebElement'" />
		</cfif>

		<cfset oJavaWebElement = arguments.WebElementReference />
	</cffunction>

	<cffunction name="getJavaWebElement" returntype="any" access="public" hint="Returns a reference to the Selenium Java WebElement-class that this component is wrapped around" >
		<cfreturn oJavaWebElement />
	</cffunction>

	<cffunction name="setSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="SelectInterfaceReference" type="SelectElement" required="true" />

		<cfset oSelectInterface = arguments.SelectInterfaceReference />
	</cffunction>

	<cffunction name="getId" returntype="string" access="public" hint="Returns the ID-attribute of this element" >
		<cfreturn getJavaWebElement().getAttribute("id") />
	</cffunction>

	<cffunction name="getClassName" returntype="string" access="public" hint="Returns the CSS class name of this element" >
		<cfreturn getJavaWebElement().getAttribute("className") />
	</cffunction>

	<cffunction name="getTagName" returntype="string" access="public" hint="Returns the tag name of this element" >
		<cfreturn getJavaWebElement().getTagName() />
	</cffunction>

	<cffunction name="getName" returntype="string" access="public" hint="Returns the Name-attribute of this element" >
		<cfreturn getJavaWebElement().getAttribute("name") />
	</cffunction>

	<cffunction name="isSelectTag" returntype="boolean" access="private" hint="Returns true if this element is a select-tag" >
		<cfset var sElementType = getJavaWebElement().getTagName() />

		<cfif sElementType EQ "select" >
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="getTextContent" returntype="string" access="public" hint="Returns the textContent-attribute of this element. That means all the visible, inner text without any of the nested HTML-tags wrapped around them or their attributes. Example: <span>Hello <span style='display: none;'>World</span></span> would return 'Hello world'" >
		<cfreturn getJavaWebElement().getAttribute("textContent") /> <!--- Only works in IE9+ --->
	</cffunction>

	<cffunction name="getHTMLContent" returntype="string" access="public" hint="Returns the inner, nested HTML and their contents of this element" >
		<cfargument name="EncodeHTMLEntities" type="boolean" required="false" default="true" hint="Set to false to get all the special HTML entities returned in their original form, otherwise they will be encoded" />

		<cfset var sReturnData = getJavaWebElement().getAttribute("innerHTML") />

		<cfif arguments.EncodeHTMLEntities >
			<cfset sReturnData = encodeForHTML(sReturnData) />
		</cfif>

		<cfreturn sReturnData />
	</cffunction>

	<cffunction name="getValue" returntype="string" access="public" hint="Returns the value-attribute of this element" >
		<cfreturn getJavaWebElement().getAttribute("value") />
	</cffunction>

	<cffunction name="getAttribute" returntype="string" access="public" hint="Returns an attribute value of this element. No matter the type of attribute it always returns a string. Boolean values are returned as 'true' or an empty string for false." >
		<cfargument name="Name" type="string" required="true" />

		<cfset var sAttributeValue = "" />

		<cfif len(arguments.Name) IS 0 OR arguments.Name IS " " >
			<cfthrow message="Error fetching attribute value of element" detail="The attribute name you passed in argument 'Name' is blank." />
		</cfif>

		<cfset sAttributeValue = getJavaWebElement().getAttribute( arguments.Name ) />

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

	<cffunction name="write" returntype="void" access="public" hint="Simulate typing into this element. For some elements this will manipulate the value-attribute" >
		<cfargument name="Text" type="array" required="true" hint="An array with each entry being a string that will be typed into the element" />

		<cftry>
			<cfset getJavaWebElement().sendKeys(arguments.Text) />

			<cfcatch type="org.openqa.selenium.ElementNotVisibleException" >
				<cfthrow message="Error when writing in element" detail="Can't write in the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>

			<cfcatch type="org.openqa.selenium.InvalidElementStateException" >
				<cfthrow message="Error when writing in element" detail="Can't write in the element, likely because it's disabled, obscured or not a type of element you can type text in. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="click" returntype="void" access="public" hint="Click this element.There are some preconditions for the element to be clicked: it must be visible and it must have a height and width greater than 0" >
		
		<cftry>
			<cfset getJavaWebElement().click() />

			<cfcatch type="org.openqa.selenium.ElementNotVisibleException" >
				<cfthrow message="Error when clicking on element" detail="Can't click on the element because it's not visible or partially hidden/obscured. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
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

	<cffunction name="select" returntype="SelectElement" access="public" hint="Returns a reference to the interface used for interacting with the special functions of a select-tag. If this element is not a select-tag then an error will be thrown" >

		<cfif isSelectTag() IS false >
			<cfthrow message="Error getting select-tag interface" detail="You can't use select-methods on this element because it's not a select-tag. Tag: #getTagName()# | id: #getID()# | Name: #getName()#" />
		</cfif>

		<cfreturn oSelectInterface />
	</cffunction>

</cfcomponent>