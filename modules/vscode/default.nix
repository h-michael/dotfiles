# VSCode with C#/Unity extensions
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # C# / .NET (Unity development)
      ms-dotnettools.csharp
      ms-dotnettools.csdevkit
      ms-dotnettools.vscode-dotnet-runtime
      ms-dotnettools.vscodeintellicode-csharp

      # Unity integration
      visualstudiotoolsforunity.vstuc
    ];
  };
}
