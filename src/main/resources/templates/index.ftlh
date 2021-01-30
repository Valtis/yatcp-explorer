<html>
	<head>
		<title>YATCP Explorer</title>
        <link rel="stylesheet" href="styles/default.css">
    	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-giJF6kkoqNQ00vy+HMDP7azOuL0xtbfIcaT9wjKHr8RbDVddVHyTfAAsrekwKmP1"    crossorigin="anonymous">
    	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js" integrity="sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW" crossorigin="anonymous"></script>

        <link rel="stylesheet" href="main.css">

        <script src="highlight.pack.js"></script>
        <script src="ansi_up.js"></script>
	</head>
	<body>

        <div class="main-container">

            <div class="insert-container">
            <label for="code"><b>Edit me!</b></label>
                <div id="code" name="code" class="editor">
extern fn write(fd: int, val buffer: byte[]);

const STDOUT = 1;

fn main() : int {
    val buffer:byte[] = "Hello, world";
    write(STDOUT, buffer);
    return 0;
}
                </div>
                <button class="btn btn-primary" onclick="compile()">Compile</button>
            </div>
            <div id="disasm" class="disasm" >

                <pre class="code-container">
                    <label for="asm"><b>Program disassembly</b></label>
                    <code id="asm">
                    </code>
                </pre>
            </div>
            <div class="output">
                <div>
                    <label for="stdout"><b>StdOut</b></label>
                    <pre id="stdout"></pre>
                </div>
                <div>
                    <label for="stderr"><b>StdErr</b></label>
                    <pre id="stderr"></pre>
                </div>
                <div>
                    <label for="exitcode"><b>Exit code</b></label>
                    <pre id="exitcode"></pre>
                </div>
                </div>
            </div>
        </div>
    </body>



    <script>
            async function compile() {
                let code = document.getElementById("code").innerText;

                let response = await fetch("/compile", {
                    method: "POST",
                    body: code
                });

                if (response.ok) {
                    let disasm_el = document.getElementById("disasm");
                    let json = await response.json();

                    code = json["asm"];

                    // hide/show the code div if disasm is present or not; mainly to save space in case errors are present
                    if (code.trim() !== "") {
                        code = hljs.highlight("x86asm", code);
                        document.getElementById("asm").innerHTML  = code.value;
                        disasm_el.style.display = "";
                    } else {
                        disasm_el.style.display = "none";
                    }

                    document.getElementById("stdout").innerText = json["program_stdout"];
                    document.getElementById("exitcode").innerText = json["return_code"];
                    stderr = json["compile_stderr"];
                    if (stderr === "") {
                        stderr = json["gcc_stderr"];
                    }
                    if (stderr === "") {
                        stderr = json["program_stderr"];
                    }

                    let ansi = new AnsiUp();

                    document.getElementById("stderr").innerHTML = ansi.ansi_to_html(stderr);
                }
            }

    </script>



    <script type="module" id="code">
      import {CodeJar} from "./codejar.js?"

      let languageDefinition =  {
          name: 'yatcp',
          alias: [ 'ytp' ],
          case_insensitive: false,
          keywords: {
                keyword: 'if else let while for fn return extern const val as continue break byte short int long float double string void',
                literal: 'false true',
          },
          contains: [
           {
              className: 'string',
              begin: '"', end: '"'
           },
           hljs.COMMENT(
              '//', // begin
              '$', // end
            )
          ]
      };



      hljs.registerLanguage("yatcp", function() { return languageDefinition } );

      const highlight = editor => {
        editor.innerHTML = hljs.highlight("yatcp", editor.textContent).value
      }


      const jar = new CodeJar(
        document.querySelector(".editor"),
        highlight
      )
    </script>

</html>
