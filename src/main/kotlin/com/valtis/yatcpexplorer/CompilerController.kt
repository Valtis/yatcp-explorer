package com.valtis.yatcpexplorer

import com.valtis.yatcpexplorer.service.CompileService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import javax.servlet.http.HttpServletResponse



@RestController
class CompilerController {



    @Autowired
    private lateinit var compileService: CompileService

    @PostMapping("compile")
    fun compile_and_run(@RequestBody code: String, response: HttpServletResponse) : String {

        val json = compileService.compile(code)

        response.status = HttpServletResponse.SC_OK;
        return json
    }
}