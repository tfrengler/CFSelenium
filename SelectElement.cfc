<cfcomponent output="false" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaSelectInterface = createObject("java", "java.lang.Object") />

	<cffunction name="init" returntype="SelectElement" access="public" hint="Constructor" >
		<cfargument name="WebElementReference" type="any" required="true" />

		<cfset var oJavaSelectInterface = createObject("java", "java.lang.Object") />

		<cfif isObject(arguments.WebElementReference) IS false >
			<cfthrow message="Argument 'WebElementReference' is not an object" />
		</cfif>
		<cfif isInstanceOf(arguments.WebElementReference, "org.openqa.selenium.remote.RemoteWebElement") IS false >
			<cfthrow message="Argument 'WebElementReference' is not an instance of 'org.openqa.selenium.remote.RemoteWebElement'" />
		</cfif>

		<cfset oJavaSelectInterface = createObject("java", "org.openqa.selenium.support.ui.Select").init( arguments.WebElementReference ) />
		<cfset setJavaSelectInterface( JavaSelectReference=oJavaSelectInterface ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getJavaSelectInterface" returntype="any" access="public" hint="Returns a reference to Selenium's Java ui.Select-class that this component is wrapped around" >
		<cfreturn oJavaSelectInterface />
	</cffunction>

	<cffunction name="setJavaSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="JavaSelectReference" type="any" required="true" />

		<cfif isObject(arguments.JavaSelectReference) IS false >
			<cfthrow message="Argument 'JavaSelectReference' is not an object" />
		</cfif>

		<cfif isInstanceOf(arguments.JavaSelectReference, "org.openqa.selenium.support.ui.Select") IS false >
			<cfthrow message="Argument 'JavaSelectReference' is not an instance of 'org.openqa.selenium.support.ui.Select'" />
		</cfif>

		<cfset oJavaSelectInterface = arguments.JavaSelectReference />
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

				<cfset oElement = createObject("component", "Element").init( WebElementReference=oCurrentWebElement ) />
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

				<cfset oElement = createObject("component", "Element").init( WebElementReference=oCurrentWebElement ) />
				<cfset arrayAppend(aListOfOptionsAsCFObjects, oElement) />

			</cfloop>
		</cfif>

		<cfreturn aListOfOptionsAsCFObjects />
	</cffunction>

	<cffunction name="getFirstSelectedOption" returntype="Element" access="public" hint="Returns the first selected option in this select tag (or the currently selected option in a normal select)" >
	
		<cfset var oElement = "" />
		<cfset var oJavaElement = "" />
		
		<cftry>
			<cfset var oJavaElement = getJavaSelectInterface().getFirstSelectedOption() />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Cannot select the first selected option because this select tag has no selected elements." />
			</cfcatch>
		</cftry>

		<cfset oElement = createObject("component", "Element").init( WebElementReference=oJavaElement ) />

		<cfreturn oElement />	
	</cffunction>

	<cffunction name="selectByVisibleText" returntype="void" access="public" hint="Select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="Text" type="string" required="true" hint="The text of the option you want to select" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByVisibleText(arguments.Text) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't select option by visible text. There's no option of this select tag with this inner text: #encodeForHTML(arguments.Text)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByIndex" returntype="void" access="public" hint="Select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting." >
		<cfargument name="Index" type="numeric" required="true" hint="The index number of the option you want to select. Note that the indexes start from 0" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByIndex(arguments.Index) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't select option by index value. The index value is likely out of bounds. Your target index: #arguments.Index# | Actual amount of options: #getNumberOfOptions()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByValue" returntype="void" access="public" hint="Select all options that have a value matching the argument. That is, when given 'foo' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="Value" type="string" required="true" hint="The value in text of the option you want to select" />
		
		<cftry>
			<cfset getJavaSelectInterface().selectByValue(arguments.Value) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't select option by value. There's no option of this select tag with this value: #encodeForHTML(arguments.Value)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectAll" returntype="void" access="public" hint="Clear all selected entries. This is only valid when this select tag supports multiple selections, otherwise an error is thrown." >
		<cftry>
			<cfset getJavaSelectInterface().deselectAll() />

			<cfcatch type="java.lang.UnsupportedOperationException" >
				<cfthrow message="Can't de-select all options in this select tag because it's not multi-select enabled." />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByValue" returntype="void" access="public" hint="Deselect all options that have a value matching the argument. That is, when given 'foo' this would deselect an option like: <option value='foo'>Bar</option>" >
		<cfargument name="Value" type="string" required="true" hint="The value in text of the option you want to de-select" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Can't de-select option by value in this select tag because it's not multi-select enabled." />
		</cfif>

		<cftry>
			<cfset getJavaSelectInterface().deselectByValue(arguments.Value) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't de-select option by value. There's no option of this select tag with this value: #encodeForHTML(arguments.Value)#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByIndex" returntype="void" access="public" hint="De-select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting." >
		<cfargument name="Index" type="numeric" required="true" hint="The index number of the option you want to de-select. Note that the indexes start from 0" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Can't de-select option by index in this select tag because it's not multi-select enabled." />
		</cfif>
		
		<cftry>
			<cfset getJavaSelectInterface().deselectByIndex(arguments.Index) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't de-select option by index value. The index value is likely out of bounds. Your target index: #arguments.Index# | Actual amount of options: #getNumberOfOptions()#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByVisibleText" returntype="void" access="public" hint="De-select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="Text" type="string" required="true" hint="The text of the option you want to de-select" />

		<cfif getJavaSelectInterface().isMultiple() IS false >
			<cfthrow message="Can't de-select option by inner text in this select tag because it's not multi-select enabled." />
		</cfif>
		
		<cftry>
			<cfset getJavaSelectInterface().deselectByVisibleText(arguments.Text) />

			<cfcatch type="org.openqa.selenium.NoSuchElementException" >
				<cfthrow message="Can't de-select option by visible text. There's no option of this select tag with this inner text: #encodeForHTML(arguments.Text)#" />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>