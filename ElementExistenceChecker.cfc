<cfcomponent output="false" hint="An interface/facade that is injected into Browser.cfc (composition). It contains handy methods designed to check the existence of elements by attribute or value. Existence checks are either binary (true/false) or based on amount." >

	<!--- PROPERTIES --->

	<cfset variables.oWrappedBrowser = "" />

	<!--- CONSTRUCTOR --->

	<cffunction name="init" returntype="ElementExistenceChecker" access="public" hint="Constructor" >
		<cfargument name="browserReference" type="Browser" required="true" />

		<cfset variables.oWrappedBrowser = arguments.browserReference />
		<cfreturn this />
	</cffunction>

	<!--- PRIVATE --->

	<cffunction name="checkElementsByTextContent" returntype="numeric" access="private" hint="Returns the amount of elements that match the text content - and optionally tag type - you supply." >
		<cfargument name="text" type="string" required="true" />
		<cfargument name="tagType" type="string" required="false" default="*" />
		<cfargument name="textMustMatchCompletely" type="boolean" required="false" default="true" />
		<cfargument name="getByDirectDescendantTextNodeOnly" type="boolean" required="false" default="false" />

		<cfset var sCheckForElementsScript = "" />
		<cfset var sXpathTextBehaviourOperator = "." />

		<cfif arguments.getByDirectDescendantTextNodeOnly >
			<!--- http://stackoverflow.com/questions/38240763/xpath-difference-between-dot-and-text --->
			<cfset sXpathTextBehaviourOperator = "text()" />
		</cfif>

		<cfset var sXpathString = "#arguments.tagType#[normalize-space(#sXpathTextBehaviourOperator#)='#jsStringFormat(arguments.text)#']" />

		<cfif NOT arguments.textMustMatchCompletely >
			<cfif NOT arguments.getByDirectDescendantTextNodeOnly >
				<cfset sXpathTextBehaviourOperator = "(.)" />
			</cfif>
			<cfset sXpathString = "#arguments.tagType#[#sXpathTextBehaviourOperator#[contains(normalize-space(.),'#jsStringFormat(arguments.text)#')]]" />
		</cfif>

		<cfoutput>
			<cfsavecontent variable="sCheckForElementsScript" >
				const findings = document.evaluate("//#trim(sXpathString)#", document);

				const returnData = [];
				var node = findings.iterateNext();

				if (!node)
					return 0;

				while (node) {
					returnData.push(node);
					node = findings.iterateNext();
				};

				return returnData.length;
			</cfsavecontent>
		</cfoutput>

		<cfreturn variables.oWrappedBrowser.runJavascript(script=sCheckForElementsScript) />
	</cffunction>

	<cffunction name="checkElementsByAttributeAndOperator" returntype="numeric" access="private" hint="The primary method for getting elements by their attributes depending on operator. The other public attribute-methods act as facades for this one." >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="operator" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfset var sSearchString = "#arguments.tagType#[#arguments.attribute##arguments.operator#='#jsStringFormat(arguments.value)#']" />

		<cfreturn variables.oWrappedBrowser.runJavascript(script="return document.querySelectorAll(""#sSearchString#"").length") />
	</cffunction>

	<!--- PUBLIC --->

	<cffunction name="byAttributeEquals" returntype="boolean" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			tagType=arguments.tagType
		) GT 0 >
	</cffunction>

	<cffunction name="byAttributeStartsWith" returntype="boolean" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="^",
			tagType=arguments.tagType
		) GT 0 >
	</cffunction>

	<cffunction name="byAttributeEndsWith" returntype="boolean" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="$",
			tagType=arguments.tagType
		) GT 0 >
	</cffunction>

	<cffunction name="byAttributeContains" returntype="boolean" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="*",
			tagType=arguments.tagType
		) GT 0 >
	</cffunction>

	<cffunction name="howManyByAttributeEquals" returntype="numeric" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			tagType=arguments.tagType
		) >
	</cffunction>

	<cffunction name="howManyByAttributeStartsWith" returntype="numeric" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="^",
			tagType=arguments.tagType
		) >
	</cffunction>

	<cffunction name="howManyByAttributeEndsWith" returntype="numeric" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="$",
			tagType=arguments.tagType
		) >
	</cffunction>

	<cffunction name="howManyByAttributeContains" returntype="numeric" access="public" hint="" >
		<cfargument name="attribute" type="string" required="false" default="" hint="" />
		<cfargument name="value" type="string" required="false" default="" hint="" />
		<cfargument name="tagType" type="string" required="false" default="" hint="" />

		<cfreturn variables.checkElementsByAttributeAndOperator(
			attribute=arguments.attribute,
			value=arguments.value,
			operator="*",
			tagType=arguments.tagType
		) >
	</cffunction>

	<cffunction name="byTextEquals" returntype="boolean" access="public" hint="" >
		<cfargument name="text" type="string" required="true" />
		<cfargument name="tagType" type="string" required="false" default="*" />

		<cfreturn variables.checkElementsByTextContent(
			text=arguments.text,
			tagType=arguments.tagType,
			textMustMatchCompletely=true
		) GT 0 />
	</cffunction>

	<cffunction name="byTextContains" returntype="boolean" access="public" hint="" >
		<cfargument name="text" type="string" required="true" />
		<cfargument name="tagType" type="string" required="false" default="*" />

		<cfreturn variables.checkElementsByTextContent(
			text=arguments.text,
			tagType=arguments.tagType,
			textMustMatchCompletely=false
		) GT 0 />
	</cffunction>

	<cffunction name="howManyByTextEquals" returntype="numeric" access="public" hint="" >
		<cfargument name="text" type="string" required="true" />
		<cfargument name="tagType" type="string" required="false" default="*" />

		<cfreturn variables.checkElementsByTextContent(
			text=arguments.text,
			tagType=arguments.tagType,
			textMustMatchCompletely=true
		) />
	</cffunction>

	<cffunction name="howManyByTextContains" returntype="numeric" access="public" hint="" >
		<cfargument name="text" type="string" required="true" />
		<cfargument name="tagType" type="string" required="false" default="*" />

		<cfreturn variables.checkElementsByTextContent(
			text=arguments.text,
			tagType=arguments.tagType,
			textMustMatchCompletely=false
		) />
	</cffunction>

</cfcomponent>