<cfcomponent modifier="final" output="false" hint="" >

	<cfset variables.sOutputFilePath = "" />
	<cfset variables.sLogFileName = "" />
	<cfset variables.nFileSizeLimit = 2 * 1024 * 1024 /> <!--- MB --->
	<cfset variables.stLogFilesStatus = {
		currentSize: 0, <!--- This is an approximation. Actual file will be slightly bigger due to the metadata of the txt-file itself --->
		fileCount: 0
	} />

	<cffunction name="init" returntype="Components.EventManager" access="public" hint="" >
		<cfargument name="logDirectory" type="string" required="true" default="" hint="An absolute path to where the log files will be stored." />

		<cfset var sNormalizedPath = reReplace(arguments.logDirectory, "/{2,}|\\{1,}|/\\|\\/", "/", "ALL") />
		<cfset var qExistingLogFiles = queryNew("") />

		<cfif NOT directoryExists(sNormalizedPath) >
			<cfthrow message="Error initializing the EventManager" detail="The log file directory you passed does not exist: #arguments.logDirectory#" />
		</cfif>

		<cfset variables.sOutputFilePath = sNormalizedPath />
		<cfset var sLogNameForToday = "EventLog_#dateFormat(now(), "dd_mm_yyyy")#" />

		<cfdirectory name="qExistingLogFiles" directory=#variables.sOutputFilePath# action="list" type="file" filter="*.txt" >
		
		<cfloop query=#qExistingLogFiles# >

			<cfif find(sLogNameForToday, qExistingLogFiles.name) GT 0 >
				<cfset variables.stLogFilesStatus.fileCount++ /> 

				<cfif qExistingLogFiles.size LT variables.nFileSizeLimit >
					<cfset variables.sLogFileName = qExistingLogFiles.name />
					<cfset variables.stLogFilesStatus.currentSize = qExistingLogFiles.size />
					<cfbreak/>
				</cfif>
			</cfif>

		</cfloop>

		<cfif len(variables.sLogFileName) IS 0 >
			<cfset variables.rotateLogFile() />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="log" returntype="void" access="public" hint="" >
		<cfargument name="objectName" type="string" required="true" hint="" />
		<cfargument name="functionName" type="string" required="true" hint="" />
		<cfargument name="parameters" type="struct" required="false" default=#structNew()# hint="" />

		<cfif len(arguments.functionName) IS 0 >
			<cfreturn />
		</cfif>

		<cfset var aLogEntry = ["[#LSTimeFormat(now(), "HH:mm:ss:l")#] #len(arguments.objectName) GT 0 ? arguments.objectName & "." : ""##arguments.functionName#():"] />
		
		<cfif NOT structIsEmpty(arguments.parameters) >
			<cfset arrayAppend(aLogEntry, variables.serializeParameters(parameters=arguments.parameters), true) />
		<cfelse>
			<cfset aLogEntry[1] = aLogEntry[1] & " NO PARAMETERS" />
		</cfif>

		<cfset arrayAppend(aLogEntry, "-------------------------------------") />
		<cfset variables.flushToDisk(data=aLogEntry) />
	</cffunction>

	<cffunction name="serializeParameters" returntype="array" access="private" hint="Serializes the parameters to strings. If structs and arrays have complex values in them, those are filtered out. Arrays and structs are only serialized one level deep, so no support for nested arrays or structs, as it's quite heavy to serialize, with a chance for the stack to overflow plus there's a risk of circular references" >
		<cfargument name="parameters" type="struct" required="true" hint="" />

		<cfset var aReturnData = [] />
		<cfset var sParameter = "" />
		<cfset var aFilteredComplexParameter = [] />
		<cfset var stFilteredComplexParameter = {} />

		<cfloop collection=#arguments.parameters# item="sParameter" >

			<cfif isSimpleValue(arguments.parameters[sParameter]) >
				<cfset arrayAppend(aReturnData, "- #sParameter#: #arguments.parameters[sParameter]#") />

			<cfelseif isArray(arguments.parameters[sParameter], 1) >

				<cfset aFilteredComplexParameter = arrayFilter(arguments.parameters[sParameter], (item)=> {
					return isSimpleValue(item)
				}) />

				<cfset arrayAppend(aReturnData, "- #sParameter#: #serializeJSON(aFilteredComplexParameter)#") />

			<cfelseif isStruct(arguments.parameters[sParameter]) >

				<cfset stFilteredComplexParameter = structFilter(arguments.parameters[sParameter], (sKey, value)=> {
					return isSimpleValue(value)
				}) />

				<cfset arrayAppend(aReturnData, "- #sParameter#: #serializeJSON(stFilteredComplexParameter)#") />
			<cfelse>
				<cfset arrayAppend(aReturnData, "- #sParameter#: (CFC or Java-object)") />
			</cfif>
		</cfloop>

		<cfreturn aReturnData />
	</cffunction>

	<cffunction name="rotateLogFile" returntype="void" access="private" hint="" >
		<cfset variables.stLogFilesStatus.fileCount++ />
		<cfset variables.stLogFilesStatus.currentSize = 0 />
		<cfset variables.sLogFileName = "EventLog_#dateFormat(now(), "dd_mm_yyyy")#_#variables.stLogFilesStatus.fileCount#.txt" />
	</cffunction>

	<cffunction name="flushToDisk" returntype="void" access="private" hint="" >
		<cfargument name="data" type="array" required="true" hint="" />

		<cfif variables.stLogFilesStatus.currentSize GT variables.nFileSizeLimit >
			<cfset variables.rotateLogFile() />
		</cfif>

		<cfset var sLogOutput = "" />
		<cfset var sFullFilePath = reReplace("#variables.sOutputFilePath#/#variables.sLogFileName#", "/{2,}|\\{1,}|/\\|\\/", "/", "ALL") />

		<cflock name="LogFileExclusiveLock" timeout="5" type="exclusive" throwontimeout="true" >
			<cfloop array=#arguments.data# index="sLogOutput" >

				<cffile 
					action="append"
					fixnewline="yes"
					output=#sLogOutput#
					file=#sFullFilePath#
					addnewline="true"
					charset="utf-8"
					nameconflict="overwrite"
				/>

				<cfset variables.stLogFilesStatus.currentSize += arrayLen(sLogOutput.getBytes()) />
			</cfloop>
		</cflock>
	</cffunction>

</cfcomponent>