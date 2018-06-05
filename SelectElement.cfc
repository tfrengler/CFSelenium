<cfcomponent output="false" hint="An interface/facade that is injected into Element.cfc (composition). It's a wrapper for Selenium's support.ui.Select-class, and contains methods specifically for interacting with select-tags." >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaSelectInterface = createObject("java", "java.lang.Object") />
	<cfset oWrappedElement = "" />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="Components.SelectElement" access="public" hint="Constructor" >
		<cfargument name="elementReference" type="Components.Element" required="true" />

		<cfset variables.oWrappedElement = arguments.elementReference />

		<cfif isObject( variables.oWrappedElement.getWrappedBrowser().getJavaloader() ) >
			<cfset setJavaSelectInterface( data=variables.oWrappedElement.getWrappedBrowser().getJavaloader().create("org.openqa.selenium.support.ui.Select").init(arguments.elementReference.getJavaWebElement()) ) />
		<cfelse>
			<cfset setJavaSelectInterface( data=createObject("java", "org.openqa.selenium.support.ui.Select").init(arguments.elementReference.getJavaWebElement()) ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<!--- PRIVATE SETTERS/GETTERS --->

	<cffunction name="setJavaSelectInterface" returntype="void" access="private" hint="" >
		<cfargument name="data" type="any" required="true" />

		<cfif isObject(arguments.data) IS false >
			<cfthrow message="Error setting Java ui.Select interface" detail="Argument 'data' is not an object" />
		</cfif>

		<cfset variables.oJavaSelectInterface = arguments.data />
	</cffunction>

	<!--- PUBLIC METHODS --->

	<cffunction name="getJavaSelectInterface" returntype="any" access="public" hint="Returns a reference to Selenium's Java support.ui.Select-class that this component is wrapped around." >
		<cfreturn variables.oJavaSelectInterface />
	</cffunction>

	<cffunction name="getNumberOfOptions" returntype="numeric" access="public" hint="Returns the amount of options belonging to this select tag" >
		<cfset var aListOfOptions = variables.oJavaSelectInterface.getOptions() />

		<cfreturn arrayLen(aListOfOptions) />
	</cffunction>

	<cffunction name="getAllOptions" returntype="array" access="public" hint="Returns an array of all options belonging to this select tag" >

		<cfset var aListOfOptionsAsCFObjects = arrayNew(1) />		
		<cfset var aListOfOptionsAsJavaObjects = variables.oJavaSelectInterface.getOptions() />
		<cfset var oCurrentWebElement = createObject("java", "java.lang.Object") />
		<cfset var oElement = "" />

		<cfif arrayLen(aListOfOptionsAsJavaObjects) GT 0 >
			<cfloop array="#aListOfOptionsAsJavaObjects#" index="oCurrentWebElement" >

				<cfset oElement = createObject("component", "Components.Element").init(
					webElementReference=oCurrentWebElement,
					browserReference=variables.oWrappedElement.getWrappedBrowser()
				) />
				<cfset arrayAppend(aListOfOptionsAsCFObjects, oElement) />

			</cfloop>
		</cfif>

		<cfreturn aListOfOptionsAsCFObjects />
	</cffunction>

	<cffunction name="getAllSelectedOptions" returntype="array" access="public" hint="Returns an array of all currently selected options belonging to this select tag" >

		<cfset var aListOfOptionsAsCFObjects = arrayNew(1) />		
		<cfset var aListOfOptionsAsJavaObjects = variables.oJavaSelectInterface.getAllSelectedOptions() />
		<cfset var oCurrentWebElement = "" />
		<cfset var oElement = "" />

		<cfif arrayLen(aListOfOptionsAsJavaObjects) GT 0 >
			<cfloop array="#aListOfOptionsAsJavaObjects#" index="oCurrentWebElement" >

				<cfset oElement = createObject("component", "Components.Element").init(
					webElementReference=oCurrentWebElement,
					browserReference=variables.oWrappedElement.getWrappedBrowser()
				) />
				<cfset arrayAppend(aListOfOptionsAsCFObjects, oElement) />

			</cfloop>
		</cfif>

		<cfreturn aListOfOptionsAsCFObjects />
	</cffunction>

	<cffunction name="getFirstSelectedOption" returntype="Components.Element" access="public" hint="Returns the first selected option in this select tag (or the currently selected option in a normal select)" >
	
		<cfset var oElement = "" />
		<cfset var oJavaElement = "" />
		
		<cftry>
			<cfset oJavaElement = variables.oJavaSelectInterface.getFirstSelectedOption() />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Error getting first selected option" detail="Cannot select the first selected option because this select tag has no selected elements | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>

		<cfset oElement = createObject("component", "Components.Element").init(
			webElementReference=oJavaElement,
			browserReference=variables.oWrappedElement.getWrappedBrowser()
		) />

		<cfreturn oElement />	
	</cffunction>

	<cffunction name="selectByVisibleText" returntype="void" access="public" hint="Select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="text" type="string" required="true" hint="The text of the option you want to select" />
		
		<cftry>
			<cfset variables.oJavaSelectInterface.selectByVisibleText(arguments.text) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Error selecting by visible text" detail="Can't select option by visible text. There's no option of this select tag with this inner text: #arguments.text# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByIndex" returntype="void" access="public" hint="Select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting." >
		<cfargument name="index" type="numeric" required="true" hint="The index number of the option you want to select. Note that the indexes start from 0" />

		<cfif variables.getNumberOfOptions() IS 0 OR (variables.getNumberOfOptions() IS 1 AND len(variables.getAllOptions()[1].getTextContent()) IS 0 ) >
			<cfthrow  message="Error selecting by index" detail="Can't select option by index value as there are no proper options in this select-tag" />
		</cfif>

		<cftry>
			<cfset variables.oJavaSelectInterface.selectByIndex(arguments.index) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow  message="Error selecting by index" detail="Can't select option by index value. The index value is likely out of bounds. Your target index: #arguments.index# | Actual amount of options: #getNumberOfOptions()# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="selectByValue" returntype="void" access="public" hint="Select all options that have a value matching the argument. That is, when given 'foo' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="value" type="string" required="true" hint="The value in text of the option you want to select" />
		
		<cftry>
			<cfset variables.oJavaSelectInterface.selectByValue(arguments.value) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow  message="Error selecting by value" detail="Can't select option by value. There's no option of this select tag with this value: #arguments.value# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectAll" returntype="void" access="public" hint="Clear all selected entries. This is only valid when this select tag supports multiple selections, otherwise an error is thrown." >
		<cftry>
			<cfset variables.oJavaSelectInterface.deselectAll() />

			<cfcatch>
				<cfif cfcatch.type IS "java.lang.UnsupportedOperationException" >
					<cfthrow message="Error deselecting all select options" detail="Can't de-select all options in this select tag because it's not multi-select enabled | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByValue" returntype="void" access="public" hint="Deselect all options that have a value matching the argument. That is, when given 'foo' this would deselect an option like: <option value='foo'>Bar</option>. Only relevant for multiple-select enabled select-tags. Will throw an exception if it is not." >
		<cfargument name="value" type="string" required="true" hint="The value in text of the option you want to de-select" />

		<cfif variables.oJavaSelectInterface.isMultiple() IS false >
			<cfthrow message="Error deselecting by value" detail="Can't de-select option by value in this select tag because it's not multi-select enabled | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
		</cfif>

		<cftry>
			<cfset variables.oJavaSelectInterface.deselectByValue(arguments.value) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Error deselecting by value" detail="Can't de-select option by value. There's no option of this select tag with this value: #arguments.value# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByIndex" returntype="void" access="public" hint="De-select the option at the given index. This is done by examining the 'index' attribute of an element, and not merely by counting. Only relevant for multiple-select enabled select-tags. Will throw an exception if it is not." >
		<cfargument name="index" type="numeric" required="true" hint="The index number of the option you want to de-select. Note that the indexes start from 0" />

		<cfif variables.oJavaSelectInterface.isMultiple() IS false >
			<cfthrow message="Error deselecting by index" detail="Can't de-select option by index in this select tag because it's not multi-select enabled | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
		</cfif>

		<cfif variables.getNumberOfOptions() IS 0 >
			<cfthrow  message="Error de-selecting by index" detail="Can't de-select option by index value as there are no options in this select-tag | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
		</cfif>
		
		<cftry>
			<cfset variables.oJavaSelectInterface.deselectByIndex(arguments.index) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Error deselecting by index" detail="Can't de-select option by index value. The index value is likely out of bounds. Your target index: #arguments.index# | Actual amount of options: #getNumberOfOptions()# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deselectByVisibleText" returntype="void" access="public" hint="De-select all options whose display text matches the argument. That is, when given 'Bar' this would select an option like: <option value='foo'>Bar</option>" >
		<cfargument name="text" type="string" required="true" hint="The text of the option you want to de-select" />

		<cfif variables.oJavaSelectInterface.isMultiple() IS false >
			<cfthrow message="Error deselecting by visible text" detail="Can't de-select option by inner text in this select tag because it's not multi-select enabled | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
		</cfif>
		
		<cftry>
			<cfset variables.oJavaSelectInterface.deselectByVisibleText(arguments.text) />

			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.NoSuchElementException" >
					<cfthrow message="Error deselecting by visible text" detail="Can't de-select option by visible text. There's no option of this select tag with this inner text: #arguments.text# | id: #variables.oWrappedElement.getID()# | Name: #variables.oWrappedElement.getName()# | Class: #variables.oWrappedElement.getClassName()#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>