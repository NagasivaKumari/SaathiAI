// PersonaEngine.ts
// Centralizes persona logic for SathiAI

export interface PersonaContext {
  userName: string;
  literacyLevel?: string;
  region?: string;
  language?: string;
  sessionId?: string;
}

export class PersonaEngine {
  constructor(private context: PersonaContext) {}

  // Generates a culturally appropriate, stepwise response
  generateResponse(query: string, aiResponse: any): any {
    // Insert local idioms, analogies, and friendly tone
    let response = aiResponse.response;
    if (this.context.language === 'hi-IN') {
      response = this.addHindiFlavor(response);
    } else if (this.context.language === 'mr-IN') {
      response = this.addMarathiFlavor(response);
    } // Add more as needed
    // Add stepwise breakdown if needed
    response = this.breakDownSteps(response);
    // Add cultural greeting
    response = this.addGreeting(response);
    return {
      ...aiResponse,
      response,
      context: this.context
    };
  }

  addHindiFlavor(text: string): string {
    // Example: add rural Hindi idioms
    return `भैया, ${text} (जैसे गाँव में कहते हैं!)`;
  }
  addMarathiFlavor(text: string): string {
    return `मित्रा, ${text} (गावातल्या भाषेत!)`;
  }
  breakDownSteps(text: string): string {
    // Example: split by sentences, add step numbers
    const steps = text.split('. ').filter(Boolean);
    if (steps.length > 1) {
      return steps.map((s, i) => `कदम ${i+1}: ${s}`).join('\n');
    }
    return text;
  }
  addGreeting(text: string): string {
    return `नमस्ते! ${text}`;
  }
}
