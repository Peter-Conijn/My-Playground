codeunit 50172 "System Log Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Page, Page::"System Log Entry", OnBeforeInsertLogEntry, '', false, false)]
    local procedure OnBeforeInsertLogEntry(var TempSystemLogEntry: Record "System Log Entry" temporary; var GlobalSystemLog: Codeunit "System Log")
    var
        SystemLogEntryExt: Codeunit "System Log Extension";
    begin
        SystemLogEntryExt.Init(GlobalSystemLog);
        SystemLogEntryExt.SetVersion(TempSystemLogEntry."Application Version");
    end;
}
