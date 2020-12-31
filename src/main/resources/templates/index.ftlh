<html>
	<head>
		<title>YATCP Explorer</title>
        <link rel="stylesheet" href="styles/default.css">
        <link rel="stylesheet" href="main.css">
        <script src="highlight.pack.js"></script>
        <script src="ansi_up.js"></script>
	</head>
	<body>

        <div class="main-container">
            <div class="insert-container">
                <textarea id="code" name="code" rows="40" cols="80" class="code-textarea">
extern fn write(fd: int, val buffer: byte[]);

const STDOUT = 1;

fn main() : int {
    val buffer:byte[] = "Hello, world";
    write(STDOUT, buffer);
    return 0;
}
                </textarea>
                <button onclick="compile()">Compile</button>
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
                let code = document.getElementById("code").value;

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
</html>
