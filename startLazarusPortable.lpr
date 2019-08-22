program startLazarusPortable;

{$mode objfpc}{$H+}

uses
      {$IFDEF UNIX}{$IFDEF UseCThreads}
      cthreads,
      {$ENDIF}{$ENDIF}
      Classes, sysutils, process, windows, RegExpr, fileinfo, laz2_XMLRead, laz2_XMLWrite, Laz2_DOM
      { you can add units after this };

const
  confPath = 'LazarusConfig\';
  lazDirEnvVar = '$LAZDIR$';

var
  lazarusDir: String;

  XMLDoc: TXMLDocument;
  nodeEnvOpt: TDOMNode;
  tmpDOMNode: TDOMNode;

  outStr: String;

  FPCCompilerDir: String;

  tmpDirString: String;

  stringListConf: TStringList;
  I: Integer;


function FileCopy(Source, Target: string): boolean;
var
  MemBuffer: TMemoryStream;
  begin
  result := false;
  MemBuffer := TMemoryStream.Create;
  try
    MemBuffer.LoadFromFile(Source);
    MemBuffer.SaveToFile(Target);
    result := true
  except
    //swallow exception; function result is false by default
  end;
  // Clean up
  MemBuffer.Free
end;

function checkLazarusInstallation: Boolean;
begin
  if FileExists(lazarusDir+'lazarus.exe') and FileExists(lazarusDir+'startlazarus.exe') and FileExists(lazarusDir+'environmentoptions.xml') and DirectoryExists(lazarusDir+'fpc') then
    Result := True
  else
    Result := False;
end;

begin
  outStr := '';
  WriteLn('startLazarusPortable v1.3');
  lazarusDir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
  WriteLn('LazarusDir: '+lazarusDir);

  Write('Checking for Lazarus installation... ');
  if checkLazarusInstallation then
    begin
      WriteLn('SUCCESS');

      Write('Loading '+lazarusDir+'environmentoptions.xml...');

      try
			  ReadXMLFile(XMLDoc,lazarusDir+'environmentoptions.xml');

        nodeEnvOpt := XMLDoc.DocumentElement.FindNode('EnvironmentOptions');

        tmpDOMNode := nodeEnvOpt.FindNode('LazarusDirectory');
        if tmpDOMNode <> Nil then
          if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
            tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := lazarusDir;
            
        tmpDOMNode := nodeEnvOpt.FindNode('CompilerFilename'); 
        if tmpDOMNode <> Nil then 
          if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
            begin
              tmpDirString := ExtractFileDir(tmpDOMNode.Attributes.GetNamedItem('Value').TextContent);
              tmpDirString := StringReplace(tmpDirString,'$(LazarusDir)',lazarusDir,[rfIgnoreCase]);
              tmpDirString := StringReplace(tmpDirString,'$LazarusDir',lazarusDir,[rfIgnoreCase]);
              FPCCompilerDir := IncludeTrailingPathDelimiter(StringReplace(tmpDirString,'\\','\',[rfReplaceAll]));
						end;

        WriteLn('DONE');

        Write('Writing back to file...');
        WriteXMLFile(XMLDoc,lazarusDir+'environmentoptions.xml');
        WriteLn('DONE');
			finally
        tmpDOMNode.Free;
        nodeEnvOpt.Free;
        XMLDoc.Free;
			end;

      Write('Checking for FPC directory...');
      if DirectoryExists(FPCCompilerDir) then
        begin
          WriteLn('SUCCESS');
          WriteLn('FPC Configuration File Location is: '+FPCCompilerDir+'fpc.cfg');
          Write('Checking for FPC Configuration File...');
          if FileExists(FPCCompilerDir+'fpc.cfg') then
            begin
              WriteLn('SUCCESS');
              Write('Editing FPC Configuration file...');

              try
                stringListConf := TStringList.Create;

                stringListConf.LoadFromFile(FPCCompilerDir+'fpc.cfg');

                WriteLn('Conf File Line Count: '+IntToStr(stringListConf.Count));

                for I := 0 to (stringListConf.Count - 1) do
                  begin
                    stringListConf.Strings[I] := ReplaceRegExpr('(-F.).+(fpc\\)',stringListConf.Strings[I],'$1'+QuoteRegExprMetaChars(lazDirEnvVar)+'$2',True);
									end;

                stringListConf.SaveToFile(FPCCompilerDir+'fpc.cfg');
                WriteLn('DONE');
					    finally
                stringListConf.Free;
						  end;
              Write('Checking for Lazarus Configuration directory...');

              if DirectoryExists(lazarusDir+confPath) then
                begin
                  WriteLn('SUCCESS');
                  Write('Checking for environmentoptions.xml...');
                  if FileExists(lazarusDir+confPath+'environmentoptions.xml') then
                    begin
                      WriteLn('SUCCESS');
                      Write('Making backup of environmentoptions.xml...');
                      if FileCopy(lazarusDir+confPath+'environmentoptions.xml',lazarusDir+confPath+'environmentoptions.xml.bak') then
                        begin
                          WriteLn('SUCCESS');
                          Write('Editing File: '+lazarusDir+confPath+'environmentoptions.xml...');

                          try
									          ReadXMLFile(XMLDoc,lazarusDir+confPath+'environmentoptions.xml');

                            nodeEnvOpt := XMLDoc.DocumentElement.FindNode('EnvironmentOptions');

                            tmpDOMNode := nodeEnvOpt.FindNode('LazarusDirectory');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('CompilerFilename');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('MakeFilename');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('TestBuildDirectory');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;
                                                                      
                            tmpDOMNode := nodeEnvOpt.FindNode('FPCSourceDirectory');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('DebuggerFilename');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;
                                                    
                            tmpDOMNode := nodeEnvOpt.FindNode('CompilerMessagesFilename');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.FindNode('History') <> Nil then
                                tmpDOMNode.FindNode('History').Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('Recent');
                            if tmpDOMNode <> Nil then
                              tmpDOMNode.Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('LastCalledByLazarusFullPath');
                            if tmpDOMNode <> Nil then
                              tmpDOMNode.Destroy;

                            tmpDOMNode := nodeEnvOpt.FindNode('LazarusDirectory');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
                                tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := lazarusDir;

                            tmpDOMNode := nodeEnvOpt.FindNode('TestBuildDirectory');
                            if tmpDOMNode <> Nil then
                              if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
                                  tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := '$(LazarusDir)\Temp\';

                            WriteLn('DONE');

                            Write('Writing back to file...');
                            WriteXMLFile(XMLDoc,lazarusDir+confPath+'environmentoptions.xml');
                            WriteLn('DONE');
									        finally
                            tmpDOMNode.Free;
                            nodeEnvOpt.Free;
                            XMLDoc.Free;
									        end;

                          //Check OnlinePackageManager Paths
                          Write('Checking for OnlinePackageManager config...');
                          if DirectoryExists(lazarusDir+confPath+'onlinepackagemanager') then
                            begin
                              if FileExists(lazarusDir+confPath+'onlinepackagemanager\config\options.xml') then
                                begin
                                  WriteLn('SUCCESS');
                                  Write('Editing OnlinePackageManager config...');

                                  try
									                  ReadXMLFile(XMLDoc,lazarusDir+confPath+'onlinepackagemanager\config\options.xml',[xrfAllowSpecialCharsInAttributeValue,xrfAllowSpecialCharsInComments,xrfPreserveWhiteSpace]);
                                                 
                                    nodeEnvOpt := XMLDoc.DocumentElement.FindNode('Folders');
                                           
                                    tmpDOMNode := nodeEnvOpt.FindNode('LocalRepositoryPackages');
                                    if tmpDOMNode <> Nil then
                                      if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
                                        tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := lazarusDir+confPath+'onlinepackagemanager\'+'packages\';
                                                      
                                    tmpDOMNode := nodeEnvOpt.FindNode('LocalRepositoryArchive');
                                    if tmpDOMNode <> Nil then
                                      if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
                                        tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := lazarusDir+confPath+'onlinepackagemanager\'+'archive\';

                                    tmpDOMNode := nodeEnvOpt.FindNode('LocalRepositoryUpdate');
                                    if tmpDOMNode <> Nil then
                                      if tmpDOMNode.Attributes.GetNamedItem('Value') <> Nil then
                                        tmpDOMNode.Attributes.GetNamedItem('Value').TextContent := lazarusDir+confPath+'onlinepackagemanager\'+'update\';

                                    WriteLn('DONE');

                                    Write('Writing OnlinePackageManager Config back to file...');
									                  WriteXMLFile(XMLDoc,lazarusDir+confPath+'onlinepackagemanager\config\options.xml',[xwfPreserveWhiteSpace,xwfSpecialCharsInAttributeValue]);
                                    WriteLn('DONE');
																	finally   
                                    tmpDOMNode.Free;
                                    nodeEnvOpt.Free;
                                    XMLDoc.Free;
																	end;
																end
                              else
                                WriteLn('FAIL');
														end
                              else
                                WriteLn('FAIL');

                          Write('Checking for editoroptions.xml...');
                          if FileExists(lazarusDir+confPath+'editoroptions.xml') then
                            begin
                              WriteLn('SUCCESS');

                              Write('Editing file: '+lazarusDir+confPath+'editoroptions.xml...');

                              try
									              ReadXMLFile(XMLDoc,lazarusDir+confPath+'editoroptions.xml');

                                nodeEnvOpt := XMLDoc.DocumentElement.FindNode('EditorOptions');
                                  
                                tmpDOMNode := nodeEnvOpt.FindNode('CodeTools');
                                if tmpDOMNode <> Nil then
                                  if tmpDOMNode.Attributes.GetNamedItem('CodeTemplateFileName') <> Nil then
                                    tmpDOMNode.Attributes.GetNamedItem('CodeTemplateFileName').TextContent := lazarusDir+confPath+'lazarus.dci';

                                WriteLn('DONE');

                                Write('Writing editoroptions.xml back to file...');
									              WriteXMLFile(XMLDoc,lazarusDir+confPath+'editoroptions.xml');
                                WriteLn('DONE');
															finally     
                                tmpDOMNode.Free;
                                nodeEnvOpt.Free;
                                XMLDoc.Free;
															end;
														end
                          else
                            WriteLn('FAIL');

                          Write('Setting environment variable "LAZDIR" to '+lazarusDir+'...');
                          if SetEnvironmentVariable('LAZDIR',PChar(lazarusDir)) then
                            begin
                              WriteLn('SUCCESS');
                              Write('Starting Lazarus...');

                              //ReadLn;

                              RunCommand('cmd',['/C','"start "" "'+lazarusDir+'startlazarus.exe" --lazarusdir="'+lazarusDir+'" --pcp="'+lazarusDir+confPath+'" --scp="'+lazarusDir+'" --skip-last-project --nsc"'],outStr);

                              WriteLn(outStr);
                            end
                          else
                            begin
                              WriteLn('FAIL');
                              WriteLn;
                              Write('Press any key to exit...');
                              ReadLn;
										        end;
								        end
                      else
                        begin
                          WriteLn('FAIL');
                          WriteLn;
                          Write('Press any key to exit...');
                          ReadLn;
				                end;
						        end
                  else
                    begin
                      WriteLn('FAIL');
                      WriteLn;
                      WriteLn('Lazarus needs to run at least once to generate config files.');
                      WriteLn('Press any key to start Lazarus...');

                      ReadLn;

		                  Write('Setting environment variable "LAZDIR" to '+lazarusDir+'...');
                      if SetEnvironmentVariable('LAZDIR',PChar(lazarusDir)) then
                        begin
                          WriteLn('SUCCESS');
                          Write('Starting Lazarus...');
                          RunCommand('cmd',['/C','"start "" "'+lazarusDir+'startlazarus.exe" --lazarusdir="'+lazarusDir+'" --pcp="'+lazarusDir+confPath+'" --scp="'+lazarusDir+'" --skip-last-project --nsc"'],outStr);
							        end
                      else
                        begin
                          WriteLn('FAIL');
                          WriteLn;
                          Write('Press any key to exit...');
                          ReadLn;
							          end;
				            end;
                end
              else
                begin
                  WriteLn('FAIL');
                  WriteLn;
                  Write('Creating Config Directory("'+lazarusDir+confPath+'")...');
                  if CreateDir(lazarusDir+confPath) then
                    begin
                      WriteLn('SUCCESS');
										end
                  else
                    begin
                      WriteLn('FAIL');
										end;

                  WriteLn;
                  Write('Press any key to exit...');
                  ReadLn;
                end;
						end
          else
            begin
              WriteLn('FAIL');
              WriteLn;
              Write('Press any key to exit...');
              ReadLn;
				    end;
				end
      else
        begin
          WriteLn('FAIL');
          WriteLn;
          Write('Press any key to exit...');
          ReadLn;
				end;
		end
  else
    begin
      WriteLn('FAIL');
      WriteLn;
      Write('Press any key to exit...');
      ReadLn;
		end;
end.

