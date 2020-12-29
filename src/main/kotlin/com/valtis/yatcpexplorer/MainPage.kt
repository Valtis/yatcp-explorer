package com.valtis.yatcpexplorer

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.servlet.ModelAndView


@Controller
class MainPage {

    @GetMapping("explorer")
    fun mainView() : ModelAndView {
        val mav = ModelAndView("index")
        return mav
    }
}