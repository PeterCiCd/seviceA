package ru.dhabits.demo.app.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.dhabits.demo.app.configuration.properties.MessageString;

@RestController
@RequiredArgsConstructor
public class controller {

    private final MessageString messageString;

    @GetMapping("/test")
    public String test() {
        return messageString.string;
    }
}
