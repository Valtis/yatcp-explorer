package com.valtis.yatcpexplorer.service

import com.fasterxml.jackson.module.kotlin.*
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.nio.file.Files
import java.util.concurrent.TimeUnit


@Service
class CompileService {

    private val logger = LoggerFactory.getLogger(CompileService::class.java)
    private val NON_ASCII_REGEX = Regex("[^\\x00-\\x7F]")
    private val NON_PRINTABLE_ASCII = Regex("[\\p{Cntrl}&&[^\r\n\t]]")

    fun compile(code: String) : String {

        var log_code = code.replace(NON_ASCII_REGEX, "").replace(NON_PRINTABLE_ASCII, "")

        logger.info("Compiling {}", log_code)
        if (code.length > 16535) {
            logger.warn("Refusing to compile, maximum length exceeded, {} bytes", code.length)
            return "{}";
        }

        val tmpFile = Files.createTempFile("yatcp-compiler-input-file", ".ytp")
        val path = tmpFile.toAbsolutePath()
        try {
            val writer = Files.newBufferedWriter(path)
            writer.use {
                writer.write(code)
            }

            val retcode = run_command(path.toString())

            logger.info("Return code: {}", retcode)
            if (retcode == -98765) {
                logger.warn("Compilation process timed out")
                return "{}"
            }

            val reader = Files.newBufferedReader(path)
            reader.use {
                val lines = reader.lines()
                val json_opt = lines.reduce { acc, str -> acc + "\n" + str }


                var json_out = json_opt.orElse("{}")
                if (json_out.trim().isEmpty()) {
                    json_out = "{}";
                }
                if (json_out.length > 65535) {

                    logger.warn("Return json length exceeds maximum length, truncating, got {}", json_out.length)
                    json_out = "{}"
                }

                val objectMapper = jacksonObjectMapper()


                val json_map: MutableMap<String, Any> = objectMapper.readValue(json_out);
                json_map.put("return_code", retcode)
                return objectMapper.writeValueAsString(json_map)
            }

        } finally {
            Files.delete(path)
        }

    }

    private fun run_command(file: String) : Int {
        val process = ProcessBuilder(
            "docker",
            "run",
            "-v", "$file:/home/compileuser/code.ytp",
            "--cap-drop", "AUDIT_WRITE",
            "--cap-drop", "CHOWN",
            "--cap-drop", "DAC_OVERRIDE",
            "--cap-drop", "FOWNER",
            "--cap-drop", "FSETID",
            "--cap-drop", "KILL",
            "--cap-drop", "MKNOD",
            "--cap-drop", "NET_BIND_SERVICE",
            "--cap-drop", "NET_RAW",
            "--cap-drop", "SETFCAP",
            "--cap-drop", "SETGID",
            "--cap-drop", "SETPCAP",
            "--cap-drop", "SETUID",
            "--cap-drop", "SYS_CHROOT",
            "yatcp-explorer").start()

        var finished = process.waitFor(10, TimeUnit.SECONDS)

        if (!finished) {
            process.destroy()
            finished = process.waitFor(10, TimeUnit.SECONDS)
            if (!finished) {
                process.destroyForcibly()
                logger.warn("Process did not terminate cleanly, killing")
            }

            return -98765
        }
        val retcode = process.exitValue()

        if (retcode != 0) {
            val bytes = process.errorStream.readAllBytes()
            logger.error("stderr: {}", String(bytes))
        }

        return retcode
    }

}