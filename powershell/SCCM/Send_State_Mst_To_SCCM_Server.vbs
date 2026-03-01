Sub RefreshServerComplianceState()
   dim newCCMUpdatesStore
   set newCCMUpdatesStore = CreateObject ("Microsoft.CCM.UpdatesStore")
   newCCMUpdatesStore.RefreshServerComplianceState
   wscript.echo "Ran RefreshServerComplianceState."
End Sub
RefreshServerComplianceState
