<cfcomponent output="false" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaSelectInterface = createObject("java", "java.lang.Object") />

	<cffunction name="init" returntype="Components.SelectElement" access="public" hint="Constructor" >
		<cfargument name="webElementReference" type="any" required="true" />
		<cfargument name="javaLoaderReference" type="any" required="false" />

		<cfif isObject(arguments.webElementReference) IS false >
			<cfthrow message="Error initializing SelectElement" detail="Argument 'webElementReference' is not an object" />
		</cfif>

		<cfif structKeyExists(arguments, "javaLoaderReference") AND isObject(arguments.javaLoaderReference) >
			<cfset setJavaSelectInterface( JavaSelectReference=arguments.javaLoaderReference.create("org.openqa.selenium.support.ui.Select").init(arguments.webElementReference) ) />
		<cfelse>
			<cfset setJavaSelectInterface( JavaSelectReference=createObject("java", "org.openqa.selenium.support.ui.Select").init(arguments.webElementReference) ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="getJavaSelectInterface" returntype="any" access="public" hint="Returns a reference to Selenium's Java ui.Select-class that this component is wrapped around." >
		<cfreturn oJavaSelectInterface />
	</cffunction>

	<cffunction name="setJavaSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="javaSelectReference" type="any" required="true" />

		<cfif isObject(arguments.javaSelectReference) IS false >
			<cfthrow message="Error setting Java select interface" detail="Argument 'javaSelectReference' is not an object" />
		</cfif>

		<cfset oJavaSelectInterface = arguments.javaSelectReference />
	</cffunction>

	<cffunction name="getNumberOfOptions" returntype="numeric" access="public" hint="Returns the amount of options belonging to this select tag" >
		<cfset var aListOfOptions = getJavaSelectInterface().getOptions() />

		<cfreturn arrayLen(aListOfOptions) />
	</cffunction>

	<cffunction name="getAllOptions" returntype="array" access="public" hint="Returns an array of all options belonging to this select tag" >

		<cfset var aListOfOptionsAsCFObjects = arrayNew(1) />		
		<cfset var aListOfOptionsAsJavaObjects = getJavaSelectInterface().getOptions() />
		<cfset var oCurrentWebElement = createObject("java", "java.lang.Object") />
		<cfset var oElement = "" />

		<cfif arrayLen(aListOfOptionsAsJavaObjects) GT 0 >
			<cfloop array="#aListOfOptionsAsJavaObjects#" index="oCurrentWebElement" >

				<cfset oElement = createObject("component", "Components.Element").init( WebElementReference=oCurrentWebElement ) />
				<cfset arrayAppend(aListOfOptionsAsCFObjects, oElement) />

			</cfloop>
		</cfif>

		<cfreturn aListOfOptionsAsCFObjects />
	</cffunction>

	<cffunction name="getAllSelectedOptions" returntype="array" access="public" hint="Returns an array of all currently selected options belonging to this select tag" >

		<cfset var aListOfOptionsAsCFObjects = arrayNew(1) />		
		<cfset var aListOfOptionsAsJavaObjects = getJavaSelectInterface().getAllSelectedOptions() />
		<cfset var oCurrentWebElement = "" />
		<cfset var oElement = "" />

		<cfif arrayLen(aListOfOptionsAsJavaObjects) GT 0 >
			<cfloop array="#aListOfOptionsAsJavaObjects#" index="oCurrentWebElement" >

				<cfset oElement = createObject("component", "Components.Element").init( WebElementReference=oCurrentWebElement ) />
				<cfset arrayAppend(aListOfOptionsAsCFObjects, oElement) />

			</cfloop>
		</cfif>

		<cfreturn aListOfOptionsAsCFObjects />
	</cffunction>

	<cffunction name="getFirstSelectedOption" returntype="Components.Element" access="public" hint="Returns the first selected option in this select tag (or the currently selected option in a normal select)" >
	
		<cfset var oElement = "" />
		<cfset var oJavaElement = "" />
		
		<cftry>
			<cfset oJavaElement = getJavaSelectInterface().getFirstSelectedOption() />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Error getting first selected option" detail="Cannot select the first selected option because this select tag has no selected elements." />
			</cfcatch>
		</cftry>

		<cfset oElement = createObject("component", "Components.Element").init( WebElementReference=oJavaElement ) />

		<cfreturn oElement />	
	</cffunction>

	<cffunction name="selectByVisibleText" returntype="void" access="public" hint="Select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="text" type="string" required="true" hint="The text of the option you want to select" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByVisibleText(arguments.text) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Error selecting by visible text" detail="Can't select option by visible text. There's no option of this select tag with this inner text: #encodeForHTML(arguments.text)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByIndex" returntype="void" access="public" hint="Select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting." >
		<cfargument name="index" type="numeric" required="true" hint="The index number of the option you want to select. Note that the indexes start from 0" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByIndex(arguments.index) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow  message="Error selecting by index" detail="Can't select option by index value. The index value is likely out of bounds. Your target index: #arguments.index# | Actual amount of options: #getNumberOfOptions()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByValue" returntype="void" access="public" hint="Select all options that have a value matching the argument. That is, when given 'foo' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="value" type="string" required="true" hint="The value in text of the option you want to select" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByValue(arguments.value) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow  message="Error selecting by value" detail="Can't select option by value. There's no option of this select tag with this value: #encodeForHTML(arguments.value)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectAll" returntype="void" access="public" hint="Clear all selected entries. This is only valid when this select tag supports multiple selections, otherwise an error is thrown." >
		<cftry>
			<cfset getJavaSelectInterface().deselectAll() />

			<cfcatch type="java.lang.UnsupportedOperationException" >
				<cfthrow message="Error deselecting all select options" detail="Can't de-select all options in this select tag because it's not multi-select enabled." />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByValue" returntype="void" access="public" hint="Deselect all options that have a value matching the argument. That is, when given 'foo' this would deselect an option like: <option value='foo'>Bar</option>" >
		<cfargument name="value" type="string" required="true" hint="The value in text of the option you want to de-select" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Error deselecting by value" detail="Can't de-select option by value in this select tag because it's not multi-select enabled." />
		</cfif>

		<cftry>
			<cfset getJavaSelectInterface().deselectByValue(arguments.value) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Error deselecting by value" detail="Can't de-select option by value. There's no option of this select tag with this value: #encodeForHTML(arguments.value)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByIndex" returntype="void" access="public" hint="De-select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting." >
		<cfargument name="index" type="numeric" required="true" hint="The index number of the option you want to de-select. Note that the indexes start from 0" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Error deselecting by index" detail="Can't de-select option by index in this select tag because it's not multi-select enabled." />
		</cfif>
		
		<cftry>
			<cfset getJavaSelectInterface().deselectByIndex(arguments.index) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Error deselecting by index" detail="Can't de-select option by index value. The index value is likely out of bounds. Your target index: #arguments.index# | Actual amount of options: #getNumberOfOptions()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByVisibleText" returntype="void" access="public" hint="De-select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="text" type="string" required="true" hint="The text of the option you want to de-select" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Error deselecting by visible text" detail="Can't de-select option by inner text in this select tag because it's not multi-select enabled." />
		</cfif>
		
		<cftry>
			<cfset getJavaSelectInterface().deselectByVisibleText(arguments.text) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Error deselecting by visible text" detail="Can't de-select option by visible text. There's no option of this select tag with this inner text: #encodeForHTML(arguments.text)#" />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>